module Spectrum
  module SearchEngines
    module Primo
      module Docs
        def self.for_json(json, position)
          return [] unless json
          position -= 1
          json.map do |doc_json|
            position += 1
            Doc.for_json(doc_json, position)
          end
        end
      end
    end
  end
end
