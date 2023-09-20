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
            prefix = metadata[:prefix] || ''
            suffix = metadata[:suffix] || ''
            value = if join
              prefix + values.join(join) + suffix
            else
              values.map { |val| prefix + val + suffix }
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
