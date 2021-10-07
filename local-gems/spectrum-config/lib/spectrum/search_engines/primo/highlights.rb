module Spectrum
  module SearchEngines
    module Primo
      class Highlights
        def self.for_json(json)
          self.new(json)
        end
        def initialize(hash)
          @raw = hash
        end
      end
    end
  end
end
