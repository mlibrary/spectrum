# frozen_string_literal: true

module Spectrum
  module Response
    class Ids

      STATUS = 302

      attr_reader :uri

      def initialize(request)
        @uri = request.uri
      end

      def status
        STATUS
      end
    end
  end
end
