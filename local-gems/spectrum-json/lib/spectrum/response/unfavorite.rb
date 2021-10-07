module Spectrum
  module Response
    class Unfavorite < Action
      attr_accessor :driver

      def initialize(request)
        super(request)
        self.driver = Spectrum::Json.actions['favorites'].driver
      end

      def spectrum
        driver.unfavorite(request.username, request.items)
      end
    end
  end
end
