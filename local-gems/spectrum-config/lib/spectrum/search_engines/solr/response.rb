module Spectrum
  module SearchEngines
    class Solr
      class Response
        attr_accessor :raw

        def self.for(raw_response)
          new(raw_response)
        end

        def initialize(raw_response)
          @raw = raw_response
        end

        def slice(start, length)
          self
        end

        def length
          raw["response"]["docs"].length
        end

        def total_items
          raw["response"]["numFound"]
        end

        def first
          raw["response"]["docs"].first
        end

        def map(&block)
          raw["response"]["docs"].map(&block)
        end
      end
    end
  end
end
