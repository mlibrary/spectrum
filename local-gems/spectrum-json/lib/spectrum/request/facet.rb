# frozen_string_literal: true

module Spectrum
  module Request
    class Facet
      include Requesty
      attr_accessor :facet_uid

      def initialize(request = nil)
        super
        @facet_uid = @data['facet_uid'] || request.params[:facet]
      end

      def search_only?
        false
      end

      def available_online?
        false
      end

      def holdings_only?
        false
      end

      def exclude_newspapers?
        false
      end

      def is_scholarly?
        false
      end

      def is_open_access?
        false
      end

      def facet_sort
        @sort
      end

      def facet_offset
        @start
      end

      def facet_limit
        @count
      end

      def query(query_map = {}, filter_map = {})
        {
          q: @tree.query(query_map),
          page: 0,
          start: 0,
          rows: 0,
          fq: @facets.query(filter_map),
          per_page: 0
        }
      end

      def spectrum
        super.merge(
          facet_uid: @facet_uid
        )
      end
    end
  end
end
