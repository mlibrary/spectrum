# frozen_string_literal: true
module Spectrum
  module Config
    class PseudoFacetField < Field
      type 'pseudo_facet'

      attr_reader :mapping

      def initialize_from_hash(args, config)
        super
        @mapping = args['mapping'] || {}
      end

      def initialize_from_instance(i)
        super
        @mapping = i.mapping
      end

      def pseudo_facet?
        true
      end
    end
  end
end
