# frozen_string_literal: true
module Spectrum
  module Config
    class HighlyRecommended
      attr_reader :field

      def initialize(config = nil)
        config ||= {}
        @field = config['field']
      end

      def map(value)
        return nil unless value.respond_to?(:downcase)
        "isfield-order-#{value.downcase.gsub(/[^a-z&']/, '_').gsub(/_+/, '_').sub(/_+$/, '')} asc"
      end

      def get_sorts(sort, facets)
        return sort.value unless field
        # If we need to limit to particular sorts, we can compare sort.uid
        (get_sorts_from_facets(facets) + [sort.value]).join(',')
      end

      def get_sorts_from_facets(facets)
        return [] unless facets.data
        facets.find(field).map { |value| map(value) }.compact
      end
    end
  end
end
