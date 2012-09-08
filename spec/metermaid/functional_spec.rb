require 'spec_helper'

describe Metermaid::SampleCollection do

	let(:data) { Metermaid::Opower::Fetcher.parse read_fixture("DailyElectricUsage.csv") }

	it "works" do
		data.samples.first.kwh.should == 1.31
	end

end
