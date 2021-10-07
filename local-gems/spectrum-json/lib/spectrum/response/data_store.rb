# frozen_string_literal: true

module Spectrum
  module Response
    class DataStore
      def initialize(args = {})
        @data = args[:data] || []
        @base_url = args[:base_url] || 'http://localhost'
      end

      def facet(name)
        @data.facet(name, @base_url)
      end

      def spectrum(args = {})
        @data.spectrum(@base_url + '/', args)
      end
    end
  end
end
