# frozen_string_literal: true

module Spectrum
  module FieldTree
    class Invalid < RuntimeError
      def query(_field_map = {})
        ''
      end

      def valid?
        false
      end
    end
  end
end
