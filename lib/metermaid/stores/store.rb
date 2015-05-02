module Metermaid
  class Store

    def initialize
      open!
    end

    def open!
    end

    def close!
    end

    def add_headlines!(source_id, headlines)
      raise "Not implemented"
    end

    def exists?(source_id, headline)
      raise "Not implemented"
    end

  end
end
