# frozen_string_literal: true
module Spectrum
  module Config
    class LabelingAggregator < Aggregator
      type 'labeling'

      def add(metadata, field, subfield)
        @ret[field] ||= {}
        @ret[field][metadata[:label]] ||= {}
        @ret[field][metadata[:label]][metadata[:join]] ||= []
        @ret[field][metadata[:label]][metadata[:join]] << subfield.value
      end

      def to_value
        @ret.values.map do |labelled_fields|
          labelled_fields.map do |joined_fields|
            join = joined_fields[1].keys.first
            values = joined_fields[1].values.first
            joined_fields[1] = if join
                                 values.join(join)
                               else
                                 values
                               end
            {
              uid: joined_fields[0],
              name: joined_fields[0],
              value: joined_fields[1],
              value_has_html: true
            }
          end
        end
      end
    end
  end
end
