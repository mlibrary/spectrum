# frozen_string_literal: true
module Spectrum
  module Config
    class AdvancedFilteringAggregator < Aggregator
      type 'advanced_filtering'

      def add(metadata, field, subfield)
        @ret[field] ||= {}
        @ret[field][metadata[:label]] ||= {}
        @ret[field][metadata[:label]][metadata[:join]] ||= []
        @ret[field][metadata[:label]][metadata[:join]] << subfield.value
      end

      def to_value
        @ret.values.map do |labelled_fields|
          [
            {
              uid: "display",
              name: "NAME",
              value: to_display_value(labelled_fields),
              value_has_html: true
            },
            {
              uid: "search",
              name: "NAME",
              value: to_search_value(labelled_fields),
              value_has_html: true
            }
          ]
        end
      end

      def to_display_value(labelled_fields)
        labelled_fields.map do |joined_fields|
          join = joined_fields[1].keys.first
          values = joined_fields[1].values.first
          if join
            values.join(join)
          else
            values
          end
        end.flatten.join(" ")
      end

      def to_search_value(labelled_fields)
        labelled_fields.map do |joined_fields|
          join = joined_fields[1].keys.first
          values = joined_fields[1].values.first
          joined_fields[1] = if join
                               values.join(join)
                             else
                               values
                             end
          joined_fields[1].map do |value|
            "#{joined_fields[0]}:#{quote(value)}"
          end.join(" AND ")
        end.flatten.join(" AND ")
      end

      def quote(str)
        "("+str.gsub(/[\(\)]/,"")+")"
      end

    end
  end
end
