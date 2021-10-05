module Spectrum
  module Response
    class ListFavorites < Action

     attr_accessor :driver

     def initialize(request)
        super(request)
        self.driver = Spectrum::Json.actions['favorites'].driver
      end

      def spectrum
        driver.list(request.username)
      end

    end
  end
end
