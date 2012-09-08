require 'spec_helper'

describe Metermaid::Sample do

	let(:sample) do
		s = Metermaid::Sample.new
		s.kwh = 1.21
		s.start_time = DateTime.parse("2000-01-01T08:00:00")
		s.duration = 3600
		s
	end

	describe "#end_time" do
		it "should get end time" do
			sample.end_time.should == DateTime.parse("2000-01-01T09:00:00")
		end
	end

end
