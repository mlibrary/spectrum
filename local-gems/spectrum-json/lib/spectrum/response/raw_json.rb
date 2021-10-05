module Spectrum
  module Response

    class RawJSON
      def initialize(string)
        @string
      end

      def to_json(_ = nil)
        @string
      end

      def to_s
        @string
      end
    end
  end
end

