module Spectrum
  module SearchEngines
    module Primo
      class Timelog
        def self.for_json(json)
          self.new(json)
        end

        def initialize(data)
          @raw = data
        end
      end
    end
  end
end
