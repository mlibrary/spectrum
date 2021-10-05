# frozen_string_literal: true

module Spectrum
  module Request
    class GetThis
      attr_reader :id, :username, :barcode

      def initialize(request)
        @id = request[:id]
        @barcode = request[:barcode]
        @username = request.env['HTTP_X_REMOTE_USER'] || ''
      end

      def logged_in?
        !@username.empty?
      end

      def can_sort?
        false
      end
    end
  end
end
