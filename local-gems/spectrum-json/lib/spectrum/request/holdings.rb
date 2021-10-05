# frozen_string_literal: true

module Spectrum
  module Request
    class Holdings
      attr_reader :id, :focus, :id_field

      def initialize(request)
        @id = request[:id]
        @focus = request[:focus]
        if @focus == 'mirlyn' and @id.length == 9
          @id_field = 'aleph_id'
        else
          @id_field = request[:id_field] || 'id'
        end
      end

      def can_sort?
        false
      end
    end
  end
end
