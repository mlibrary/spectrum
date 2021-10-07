# frozen_string_literal: true

module Spectrum
  module Response
    class File
      attr_accessor :request, :driver

      def initialize(request)
        self.request = request
        self.driver  = Spectrum::Json.actions['file'].driver
      end

      def data
        driver.message(request.items)
      end
    end
  end
end
