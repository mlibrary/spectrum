# frozen_string_literal: true

module Spectrum
  module Fieldtree
    class ValueBoolean < Base
      TYPES = {
        'tag' => Spectrum::FieldTree::Tag,
        'literal' => Spectrum::FieldTree::Literal,
        'special' => Spectrum::FieldTree::Special,
        'value_boolean' => Spectrum::FieldTree::ValueBoolean
      }.freeze
      def query(field_map = {})
        @children.map { |item| item.query(field_map) }.join(" #{@value} ")
      end
    end
  end
end
