module Spectrum
  module Response
    class SuggestFavorites < Action

     attr_accessor :driver

     def initialize(request)
        super(request)
        self.driver = Spectrum::Json.actions['favorites'].driver
      end

      def spectrum
        driver.suggest(request.username)
      end

    end
  end
end
