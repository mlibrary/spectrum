# frozen_string_literal: true
module Spectrum
  module Config
    class HighlyRecommendedField < Field
      type 'highly_recommended'

      def value(data, request = nil)
        return nil unless request && request.respond_to?(:facets)
        topics = request.facets.data[facet_field]&.select do |value|
          key = field + value.downcase.gsub(/[^a-z'&]/, '_').gsub(/_+/, '_').sub(/_+$/, '')
          data[key].to_i < 100
        end
        return nil unless topics && topics.length > 0
        topics
      end
    end
  end
end

