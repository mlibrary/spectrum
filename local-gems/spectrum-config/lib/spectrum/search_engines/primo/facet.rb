module Spectrum
  module SearchEngines
    module Primo
      class Facet
        attr_reader :name, :values
        alias :display_name :name
        alias :counts :values

        def self.for_json(data)
          self.new(
            name: data['name'],
            values: data['values'].map {|value| FacetValue.for_json(value)}
          )
        end

        def initialize(name: "unnamed facet", values: [])
          @name = name
          @values = values
        end
      end
    end
  end
end
