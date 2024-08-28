# frozen_string_literal: true
module Spectrum
  module Config
    class ConditionalMappedFacetField < Field
      type 'conditional_mapped_facet'

      attr_reader :mapping, :condition

      def initialize_from_hash(args, config)
        super
        @mapping = args['mapping'] || {}
        @condition = args['condition'] || {}
      end

      def initialize_from_instance(i)
        super
        @mapping = i.mapping
        @condition = i.condition
      end

    end
  end
end
