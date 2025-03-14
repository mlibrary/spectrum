module Spectrum
  module SearchEngines
    module Primo
      module Facets
        def self.for_json(json)
          return [] unless json
          json.map {|data| Facet.for_json(data) }
        end
      end
    end
  end
end
