require 'date'
require 'time'
require 'nokogiri'

module Metermaid
  # Represents a collection of samples. In some cases it's useful to operate on
  # groups of samples and this class provides that functionality.
  class SampleCollection

    attr_accessor :samples

    def initialize(samples_array)
      self.samples = samples_array
      sort_by_date!
    end

    def sort_by_date!
      samples = self.samples.sort {|a,b| a.start_time.to_i <=> b.start_time.to_i }
    end

    def start_time
      samples.first.start_time
    end

    def end_time
      samples.last.end_time
    end

    def time_range
      [start_time..end_time]
    end

  #   # Calculates the total number of kilowatt hours for all samples.
  #   #
  #   # @return [Float] the sum of kilowatt hours for all samples within this collection. If no samples are found 0 is  returned.
  #   def total_kwh
  #     self.keys.reduce(0) { |sum, d| sum + total_kwh_on(d) }
  #   end

  #   # Calculates the total number of kilowatt hours
  #   #
  #   # @param [Date] date The date of the samples to include within the total.
  #   #
  #   # @return [Float] the sum of kilowatt hours for samples made of the given day. If none are found 0 is returned.
  #   def total_kwh_on(date)
  #     if self[date]
  #       self[date].reduce(0) { |sum, s| sum + (s.kwh or 0) }
  #     else
  #       0
  #     end
  #   end
  end

end
