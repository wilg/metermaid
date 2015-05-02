module Metermaid
  module PGandE
    module Fetcher

      require 'mechanize'
      require 'zip'
      require 'tempfile'
      require 'csv'

      def self.scrape!(username:, password:, start_date:, end_date:, additional_metadata: {})
        base_url = "http://www.pge.com/"
        agent = Mechanize.new
        page = agent.get(base_url)
        login_form = page.forms_with(method: "POST").first
        login_form.USER = username
        login_form.PASSWORD = password
        page = agent.submit(login_form, login_form.buttons.first)
        page = agent.page.link_with(:text => 'My Usage').click
        page = page.forms.first.submit
        page = page.forms.first.submit
        export_form_url = page.link_with(text: "Green Button - Download my data").href
        export_page = agent.get(export_form_url)
        export_url_base = export_page.forms.first.action
        file = agent.get("#{export_url_base}?exportFormat=ESPI_AMI&bill=&xmlFrom=#{CGI.escape(start_date.strftime("%m-%d-%Y"))}&xmlTo=#{CGI.escape(end_date.strftime("%m-%d-%Y"))}")
        files_to_rows(decompress(file), additional_metadata)
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
            .merge({filename: additional_metadata[:filename]})
          entry = Hash[Sparsify(entry, separator: "-").map{|k, v| [k.underscore.to_sym, v]}.reject{|v| v[0].to_s.include?("xmlns")}]
          additional_metadata.delete(:filename)
          entry[:additional_metadata] = additional_metadata.as_json
          entry[:sample_hash] = entry.except(:value, :filename).sort.join("_")
          entry
        end
      end

    end
  end
end
