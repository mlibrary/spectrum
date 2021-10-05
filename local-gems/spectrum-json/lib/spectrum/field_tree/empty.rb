# frozen_string_literal: true

module Spectrum
  module FieldTree
    class Empty
      def query(_field_map = {})
        '*:*'
      end

      def valid?
        true
      end

      def spectrum
        {}
      end

      def params(_field_map)
        {}
      end
    end
  end
end
