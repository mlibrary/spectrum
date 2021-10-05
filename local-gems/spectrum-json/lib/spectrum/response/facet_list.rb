# frozen_string_literal: true

module Spectrum
  module Response
    class FacetList
      include Spectrumable

      def initialize(args = {})
        @datastore = args[:datastore]
        @facet     = args[:facet]
        @base_url  = args[:base_url] || 'http://localhost'
      end

      def total_available
        nil
      end

      def spectrum
        @datastore.facet(@facet)[:values]
      end
    end
  end
end
