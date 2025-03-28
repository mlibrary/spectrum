# frozen_string_literal: true

module Spectrum
  module Request
    class GetThis
      attr_reader :id, :username, :barcode

      def initialize(request:, username:)
        data = if request.respond_to?(:[])
          request
        elsif request.respond_to?(:params)
          request.params
        else
          {}
        end
        @id = data[:id]
        @barcode = data[:barcode]
        @username = username || ""
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
