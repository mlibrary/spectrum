# frozen_string_literal: true

module Spectrum
  module Response
    class DataStoreList
      def initialize(args = {})
        list = args[:data] || []
        base_url = args[:base_url] || 'http://localhost'
        @list = list.values.map { |item| DataStore.new(data: item, base_url: base_url) }
      end

      def total_available
        @list.length
      end

      def spectrum(args = {})
        @list.map { |item| item.spectrum(args) }
      end
    end
  end
end
