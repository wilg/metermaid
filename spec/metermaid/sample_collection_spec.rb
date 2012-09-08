require 'spec_helper'

describe Metermaid::SampleCollection do

	before(:all) { @data = Metermaid::Opower::Fetcher.parse read_fixture("DailyElectricUsage.csv") }
	let(:data){ @data }

	it "works" do
		data.samples.first.kwh.should == 1.31
	end

	describe "#start_time" do
		it "should get the earliest time" do
			data.start_time.should == DateTime.parse("2012-07-25T00:00:00#{DateTime.now.zone}")
		end
	end

	describe "#end_time" do
		it "should get the latest time" do
			data.end_time.should == DateTime.parse("2012-08-24T00:00:00#{DateTime.now.zone}")
		end
	end

end
