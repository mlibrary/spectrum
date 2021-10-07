module Spectrum
  module Request
    class Tag < Action
      def tags
        @data['to'] || []
      end
    end
  end
end
