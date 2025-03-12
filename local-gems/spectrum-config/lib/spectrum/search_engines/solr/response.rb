module Spectrum
  module SearchEngines
    class Solr
      class Response
        attr_accessor :raw

        def self.for(raw_response)
          new(raw_response)
        end

        def self.for_nothing
          new({"response" => {"docs" => [], "numFound" => 0}, "facet_counts" => {"facet_fields" => {}}})
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

        def total_items_magnitude
          return 0 if total_items < 1
          Math.log10(total_items).ceil
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
