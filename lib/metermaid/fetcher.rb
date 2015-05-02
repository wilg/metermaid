module Metermaid
  module PGandE
    module Fetcher

      require 'mechanize'
      require 'zip'
      require 'tempfile'
      require 'csv'

      def self.scrape!(options = {})
        base_url = "http://www.pge.com/"
        agent = Mechanize.new
        page = agent.get(base_url)
        login_form = page.forms_with(method: "POST").first
        login_form.USER = options[:username]
        login_form.PASSWORD = options[:password]
        page = agent.submit(login_form, login_form.buttons.first)
        page = agent.page.link_with(:text => 'My Usage').click
        page = page.forms.first.submit
        page = page.forms.first.submit
        export_form_url = page.link_with(text: "Green Button - Download my data").href
        export_page = agent.get(export_form_url)
        export_url_base = export_page.forms.first.action
        file = agent.get("#{export_url_base}?exportFormat=ESPI_AMI&bill=&xmlFrom=04%2F18%2F2015&xmlTo=04%2F29%2F2015")
        files_to_rows(decompress(file), options[:additional_metadata] || {})
      end

      def self.decompress(file)
        tempfile = Tempfile.new(['opower', 'zip'])
        files = {}
        Zip::File.open(file.save(tempfile.path)) do |zip_file|
          zip_file.each do |entry|
            files[entry.name] = entry.get_input_stream.read
          end
        end
        files
      end

      def self.files_to_rows(file_hash, additional_metadata = {})
        rows = []
        file_hash.each do |k, v|
          rows.concat to_rows(v, additional_metadata.merge(filename: k))
        end
        rows
      end

      def self.to_rows(xml, additional_metadata = {})
        entries = Hash.from_xml(xml)["feed"]["entry"]
        usage_data = entries.find{|e| e["content"]["IntervalBlock"] rescue nil}["content"]["IntervalBlock"]
        reading_type = entries.find{|e| e["content"]["ReadingType"] rescue nil}["content"]["ReadingType"]
        usage_point = entries.find{|e| e["content"]["UsagePoint"] rescue nil}

        data = usage_data["IntervalReading"].map do |entry|
          entry = entry
            .merge({reading_type: reading_type})
            .merge({address: usage_point["title"], usage_point: usage_point["content"]["UsagePoint"]})
            .merge(additional_metadata)
          Hash[Sparsify(entry, separator: "-").map{|k, v| [k.underscore, v]}.reject{|v| v[0].include?("xmlns")}]
        end
      end

      def self.parse(text)
        hashes = hashify_csv text
        # {:type=>"Electric usage", :date=>"2012-07-25", :start_time=>"00:00", :end_time=>"00:59", :usage=>"1.31", :units=>"kWh", :notes=>nil}
        samples = []
        hashes.each do |item|
          if item[:type] == "Electric usage"

            sample = Sample.new

            # Start Time
            start_time = DateTime.parse "#{item[:date]} #{item[:start_time]}#{DateTime.now.zone}"
            sample.start_time = start_time

            # End Time
            end_time = DateTime.parse "#{item[:date]} #{item[:end_time]}"
            duration = (end_time.to_time - sample.start_time.to_time).to_i
            sample.duration = duration == 3540 ? 3600 : duration # Opower incorrectly says that the period is 59 minutes when they actually mean 60

            # Units
            if item[:units] == "kWh"
              sample.kwh = item[:usage].to_f
            else
              raise "Using unsupported unit: #{item[:units]}"
            end

            samples << sample

          else
            raise "Using unsupported type: #{item[:type]}"
          end
        end
        SampleCollection.new(samples)
      end

      private

      def self.hashify_csv(csv_text)
        csv = CSV.parse(csv_text).to_a
        start = false
        header_index = nil
        csv.each_with_index do |line, index|
          if line == []
            header_index = index + 1
            break
          end
        end
        header = csv[header_index]
        csv.shift header_index + 1
        items = []
        csv.each do |line|
          item = {}
          header.each_with_index do |k, i|
            item[k.to_s.downcase.gsub(" ", "_").to_sym] = line[i]
            items << item
          end
        end
        items
      end

    end
  end
end
