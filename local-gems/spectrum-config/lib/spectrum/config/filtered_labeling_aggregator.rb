# frozen_string_literal: true
module Spectrum
  module Config
    class FilteredLabelingAggregator < Aggregator
      type 'filtered_labeling'

      def add(metadata, field, subfield)
        @ret[field] ||= {}
        @ret[field][metadata[:label]] ||= {}
        @ret[field][metadata[:label]][metadata[:join]] ||= {}
        @ret[field][metadata[:label]][metadata[:join]][metadata[:filters]] ||= []
        @ret[field][metadata[:label]][metadata[:join]][metadata[:filters]] << {subfield.code => subfield.value}
      end

      def sub_exists_filter(code_match, sub_match, fields)
        return fields unless fields.any? { |field| sub_match.match(field.to_a.first.first) }
        fields.reject do |code_value|
          code, value = code_value.to_a.first
          code_match.match?(code)
        end
      end

      def value_match_filter(code_match, value_match, fields)
        fields.reject do |code_value|
          code, value = code_value.to_a.first
          code_match.match?(code) && value_match.match?(value)
        end
      end

      def apply_filter(filter, fields)
        if (value_match = filter[:value_match])
          value_match_filter(Regexp.new(filter[:sub]), Regexp.new(value_match), fields)
        elsif (sub_match = filter[:sub_exists])
          sub_exists_filter(Regexp.new(filter[:sub]), Regexp.new(sub_match), fields)
        else
          fields
        end
      end

      def apply_filters(filters, fields)
        (filters || []).each do |filter|
          fields = apply_filter(filter, fields)
        end
        fields.map(&:values).flatten
      end

      def to_value
        @ret.values.map do |label_join_filters_fields|
          label_join_filters_fields.map do |label, join_filters_fields|
            join, filters_fields = join_filters_fields.to_a.first
            filters, fields = filters_fields.to_a.first
            filtered_fields = apply_filters(filters, fields)
            values = if join
              filtered_fields.join(join)
            else
              filtered_fields
            end

            {
              uid: label,
              name: label,
              value: values,
              value_has_html: true
            }
          end
        end
      end
    end
  end
end
