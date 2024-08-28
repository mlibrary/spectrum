# frozen_string_literal: true

module Spectrum
  module Request
    class Record

      FLINT = 'Flint'
      FLINT_PROXY_PREFIX = 'http://libproxy.umflint.edu:2048/login?qurl='
      DEFAULT_PROXY_PREFIX = 'https://proxy.lib.umich.edu/login?qurl='
      INSTITUTION_KEY = 'dlpsInstitutionId'

      def proxy_prefix
        return FLINT_PROXY_PREFIX if @request.env[INSTITUTION_KEY]&.include?(FLINT)
        DEFAULT_PROXY_PREFIX
      end

      def messages
        []
      end

      def initialize(request)
        @request = request
        if request.params[:source] == 'summon'
          @query = "#{@request.params['id_field']}:#{unfiltered_id(request)}"
        elsif request.params[:source] == 'mirlyn'
          id_field = @request.params['id_field']
          id = unfiltered_id(request)
          if id.length == 9
            id_field = 'aleph_id'
          end
          @query = "#{id_field}:#{id}"
        else
          @query = "#{@request.params['id_field']}:#{RSolr.solr_escape(unfiltered_id(request))}"
        end
      end

      def can_sort?
        false
      end

      def unfiltered_id(request)
        path = request.path
        original = request.original_fullpath
        id = request.params[:id]
        original.slice(path.length - id.length, original.length)
      end

      def authenticated?
        # When @request is nil, the server is making the request for it's own information.
        return true unless @request&.env

        # If there's a @request.env, but not a dlpsInstitutionId then it's empty.
        return false unless @request.env['dlpsInstitutionId']

        # If we found an institution we're authenticated.
        @request.env['dlpsInstitutionId'].length > 0
      end

      def available_online?
        false
      end

      def not_search_only?
        false
      end

      def search_only?
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

      def book_mark?
        @request.params['type'] == 'Record' && @request.params['id_field'] == 'BookMark'
      rescue StandardError
        false
      end

      def book_mark
        @request.params['id']
      rescue StandardError
      end

      def holdings_only?
        # TODO: Check this for when we implement this completely.

        if @data['facets']['holdings_only'].nil?
          true
        else
          Array(@data['facets']['holdings_only']).include?('true')
        end
      rescue StandardError
        true
      end

      def sort; end

      def slice
        [0, 1]
      end

      def query(_query_map = {}, _filter_map = {})
        {
          q: @query,
          page: 0,
          start: 0,
          rows: 1,
          fq: [],
          per_page: 1
        }
      end

      def facet_uid
        nil
      end

      def facet_sort
        nil
      end

      def facet_offset
        nil
      end

      def facet_limit
        nil
      end

      def fvf
        nil
      end

      def rff
        nil
      end

      def rf
        nil
      end
    end
  end
end
