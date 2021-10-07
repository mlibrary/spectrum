# frozen_string_literal: true

module Spectrum
  module Fieldtree
    class Tag < Base
      TYPES = {
        'tag' => Spectrum::FieldTree::Tag,
        'literal' => Spectrum::FieldTree::Literal,
        'special' => Spectrum::FieldTree::Special,
        'value_boolean' => Spectrum::FieldTree::ValueBoolean
      }.freeze
    end
  end
end
