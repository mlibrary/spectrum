module Spectrum
  module Response
    class Tag < Action
      attr_accessor :driver

      def initialize(request)
        super(request)
        self.driver = Spectrum::Json.actions['favorites'].driver
      end

      def spectrum
        driver.tag(request.username, request.tags, request.items)
      end
    end
  end
end
