# frozen_string_literal: true
module Spectrum
  module Config
    class LabelingAggregator < Aggregator
      type 'labeling'

      def add(metadata, field, subfield)
        @ret[field] ||= {}
        @ret[field][metadata] ||= []
        @ret[field][metadata] << subfield.value
      end

      def to_value
        @ret.values.map do |metadata_values|
          metadata_values.map do |metadata, values|
            label = metadata[:label]
            join = metadata[:join]
            value_append = metadata[:append] || ''
            value_prepend = metadata[:prepend] || ''
            value = if join
              value_prepend + values.join(join) + value_append
            else
              values.map { |val| value_prepend + val + value_append }
            end

            {
              uid: label,
              name: label,
              value: value,
              value_has_html: true
            }
          end
        end
      end
    end
  end
end
