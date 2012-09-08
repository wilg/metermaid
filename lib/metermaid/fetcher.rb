module Metermaid
  module Opower
		module Fetcher

			require 'mechanize'
			require 'zip/zip'
			require 'tempfile'
			require 'csv'

			def self.scrape!(options = {})
				base_url = "https://#{options[:subdomain]}.opower.com"
				agent = Mechanize.new
				page = agent.get(base_url)
				page = agent.page.link_with(:text => 'Sign In').click
				login_form = page.form('login-form')
				login_form.j_username = options[:username]
				login_form.j_password = options[:password]
				page = agent.submit(login_form, login_form.buttons.first)
				page = agent.page.link_with(:text => 'My Energy Use').click
				page = agent.page.link_with(:text => 'Export your data').click
				export_form = page.form
				file = agent.get("#{base_url}#{export_form.action}?exportFormat=CSV_AMI&bill=#{options[:year] || Time.now.year}-#{options[:bill] || 1}")
				self.parse(self.decompress(file, "DailyElectricUsage.csv"))
			end

			def self.decompress(file, filename)
				tempfile = Tempfile.new(['opower', 'zip'])
				actualpath = tempfile.path + "2"
				file.save actualpath
				out = ""
				Zip::ZipFile.open(actualpath, Zip::ZipFile::CREATE) do |zipfile|
					out = zipfile.read(filename)
				end
				out
			end

			def self.parse(text)
				hashes = hashify_csv text
				# {:type=>"Electric usage", :date=>"2012-07-25", :start_time=>"00:00", :end_time=>"00:59", :usage=>"1.31", :units=>"kWh", :notes=>nil}
				samples = []
				hashes.each do |item|
					if item[:type] == "Electric usage"
						sample = Sample.new
						sample.start_time = DateTime.parse "#{item[:date]} #{item[:start_time]}"
						end_time = DateTime.parse "#{item[:date]} #{item[:end_time]}"
						duration = (end_time.to_time - sample.start_time.to_time).to_i
						sample.duration = duration == 3540 ? 3600 : duration # Opower incorrectly says that the period is 59 minutes when they actually mean 60 
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
