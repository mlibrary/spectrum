# frozen_string_literal: true

module Spectrum
  module Request
    class Holdings
      attr_reader :id, :focus, :id_field

      def initialize(request)
        data = if request.respond_to?(:[])
          request
        elsif request.respond_to?(:params)
          request.params
        else
          {}
        end

        @id = data[:id]
        @focus = data[:focus]
        if @focus == 'mirlyn' and @id.length == 9
          @id_field = 'aleph_id'
        else
          @id_field = data[:id_field] || 'id'
        end
      end

      def can_sort?
        false
      end
    end
  end
end
