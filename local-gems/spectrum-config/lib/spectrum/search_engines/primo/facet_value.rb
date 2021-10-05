module Spectrum
  module SearchEngines
    module Primo
      class FacetValue
        attr_reader :value, :count

        def self.for_json(json)
          self.new(value: json['value'], count: json['count'].to_i)
        end

        def applied?
          false
        end

        def initialize(value: 'unknown value', count: 0)
          @value = value
          @count = count
        end
      end
    end
  end
end
