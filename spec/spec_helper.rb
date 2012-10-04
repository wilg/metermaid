require 'simplecov'
require 'coveralls'

SimpleCov.start
SimpleCov.formatter = Coveralls::SimpleCov::Formatter

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

require_relative "../lib/metermaid"

def read_fixture filename
		open(File.expand_path(File.join(__FILE__, "..", "fixtures", filename)), "r") do |f|
			return f.read
		end
end