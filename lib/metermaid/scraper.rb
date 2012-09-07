module Metermaid
  module Opower
		module Scraper

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
				CSV.parse(text).to_a
			end

		end
  end
end
