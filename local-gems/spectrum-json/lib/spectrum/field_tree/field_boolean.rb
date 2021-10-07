# frozen_string_literal: true

module Spectrum
  module FieldTree
    class FieldBoolean < Base
      def query(field_map = {})
        @children.map { |item| item.query(field_map) }.join(" #{@value} ")
      end
    end
  end
end
