# frozen_string_literal: true
module Spectrum
  module Config
    class FieldAggregator < Aggregator
      type 'field'

      def initialize
        super
      end

      def add(metadata, field, subfield)
        return unless subfield
        @ret[field] ||= []
        @ret[field] << [metadata[:label], subfield]
      end

      def to_value
        ret = []
        @ret.each_pair do |field, pairs|
          val = []
          pairs.each do |pair|
            label, subfield = pair
            val << {
              uid: label || "#{field.tag}#{subfield.code}",
              name: label,
              value: subfield.value,
              value_has_html: true
            }
          end
          ret << val unless val.empty?
        end
        ret
      end
    end
  end
end
