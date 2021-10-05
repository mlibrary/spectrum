module Spectrum
  module Request
    class Untag < Action
      def tags
        @data['to'] || []
      end
    end
  end
end
