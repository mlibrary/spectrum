# frozen_string_literal: true
module Spectrum
  module Config
    class HighlyRecommendedField < Field
      type 'highly_recommended'

      def value(data, request = nil)
        return nil unless request && request.respond_to?(:facets)
        topics = request.facets.data[facet_field]&.select do |value|
          key = prefix +
                  value.downcase.gsub(/[^a-z'&]/, '_').gsub(/_+/, '_').sub(/_+$/, '') +
                  suffix
          data[key] && data[key].to_i < 100
        end
        return nil unless topics && topics.length > 0
        topics
      end

      def prefix
        return '' unless field.end_with?('*')
        field[0...-1]
      end

      def suffix
        return '' unless field.start_with?('*')
        field[1...field.length]
      end
    end
  end
end

