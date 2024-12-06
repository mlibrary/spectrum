# frozen_string_literal: true
module Spectrum
  module Config
    class HighlyRecommended
      attr_reader :field, :prefix, :suffix

      def initialize(config = nil)
        config ||= {}
        @field = config['field']
        @prefix = config['prefix'] || ''
        @suffix = config['suffix'] || ''
      end

      def map(value)
        return nil unless value.respond_to?(:downcase)
        "#{prefix}#{value.downcase.gsub(/[^a-z&'.]/, '_').gsub(/_+/, '_').sub(/_+$/, '')}#{suffix} asc"
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
