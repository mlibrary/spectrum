# frozen_string_literal: true

module Spectrum
  module Request
    module Requesty
      extend ActiveSupport::Concern

      FLINT                = 'Flint'
      FLINT_PROXY_PREFIX   = 'http://libproxy.umflint.edu:2048/login?qurl='
      DEFAULT_PROXY_PREFIX = 'https://proxy.lib.umich.edu/login?qurl='
      INSTITUTION_KEY      = 'dlpsInstitutionId'

      included do
        attr_accessor :request_id, :slice, :sort, :start, :messages, :count
      end

      def can_sort?
        true
      end

      def proxy_prefix
        return FLINT_PROXY_PREFIX if @request.env[INSTITUTION_KEY]&.include?(FLINT)
        DEFAULT_PROXY_PREFIX
      end

      def is_new_parser?(focus, data)
        focus and
            focus.new_parser? and
            data.has_key?('raw_query') and
            data['raw_query'].match(/\S/)
      end

      def initialize(request = nil, focus = nil)
        @request  = request
        @focus    = focus
        @data     = get_data(@request)
        @messages = []
        if (@data)
          bad_request 'Request json did not validate' unless Spectrum::Json::Schema.validate(:request, @data)

          @is_new_parser = is_new_parser?(@focus, @data)
          if @is_new_parser
            @psearch = build_psearch
            @psearch.errors.each do |msg|
              @messages << Spectrum::Response::Message.error(
                summary: "Query Parse Error",
                details: msg.details,
                data: msg.to_h
              )
            end
            @psearch.warnings.each do |msg|
              @messages << Spectrum::Response::Message.warn(
                summary: "Query Parse Warning",
                details: msg.details,
                data: msg.to_h,
              )
            end
          end

          ##############################
          ##############################


          @uid        = @data['uid']
          @start      = @data['start'].to_i
          @count      = @data['count'].to_i
          @page       = @data['page']
          @tree       = Spectrum::FieldTree.new(@data['field_tree'])
          @facets     = Spectrum::FacetList.new(@focus.default_facets.merge(@focus.filter_facets(@data['facets'] || {})))
          @sort       = @data['sort']
          @settings   = @data['settings']
          @request_id = @data['request_id']


          if @page || @count == 0
            @page_size = @count
          elsif @start < @count
            @slice       = [@start, @count]
            @page_size   = @start + @count
            @page_number = 0
          else
            last_record  = @start + @count
            @page_size   = @count
            @page_number = (@start / @page_size).floor

            while @page_number > 0 && @page_size * (@page_number + 1) < last_record
              first_record = @page_size * @page_number
              if @start - first_record < @page_number
                @page_size = (last_record / @page_number).ceil
              else
                @page_size += (@start - first_record).floor
              end
              @page_number = (@start / @page_size).floor
            end
            @slice = [@start - @page_size * @page_number, @count]
          end

          validate!
        end
        @page = (@page_number || 0) + 1

        @start ||= 0
        @count ||= 0
        @slice ||= [0, @count]

        @tree      ||= Spectrum::FieldTree::Empty.new
        @facets    ||= Spectrum::FacetList.new(nil)
        @page_size ||= 0
      end

      def pseudo_facet?(name, default = false)
        return default if @data.nil? || @data['facets'].nil? || @data['facets'][name].nil?
        Array(@data['facets'][name]).include?('true')
      end

      # TODO: Find a way to make this configurable
      def available_online?
        pseudo_facet?('available_online')
      end

      def not_search_only?
        !search_only?
      end

      def search_only?
        @focus && @focus.id == 'mirlyn' && pseudo_facet?('search_only', false)
      end

      def holdings_only?
        pseudo_facet?('holdings_only', true)
      end

      def exclude_newspapers?
        pseudo_facet?('exclude_newspapers')
      end

      def is_scholarly?
        pseudo_facet?('is_scholarly')
      end

      def is_open_access?
        pseudo_facet?('is_open_access')
      end

      def book_mark?
        @request.params['type'] == 'Record' && @request.params['id_field'] == 'BookMark'
      rescue StandardError
        false
      end

      def book_mark
        @request.params['id']
      end

      def authenticated?
        # When @request is nil, the server is making the request for it's own information.
        return true unless @request&.env

        # If there's a @request.env, but not a dlpsInstitutionId then it's empty.
        return false unless @request.env['dlpsInstitutionId']

        # If we found an institution we're authenticated.
        @request.env['dlpsInstitutionId'].length > 0
      end

      def get_data(request)
        if request&.respond_to?(:post?) && request&.post?
          JSON.parse(request.raw_post)
        elsif Hash === request
          request
        else
          nil
        end
      end

      # For summon's range filter (i.e. an applied filter)
      def rf
        @focus ? @focus.rf(@facets) : []
      end

      # For summon's range filter facet (i.e. a filter to ask for counts of)
      def rff
        @focus ? @focus.rff(@facets) : []
      end

      def fvf(_filter_map = {})
        @focus ? @focus.fvf(@facets) : []
      end


      def new_parser_query(query_map = {}, filter_map = {}, built_search = @psearch)
        lp = @focus.transformer.new(built_search)
        base_query(query_map, filter_map).merge(lp.params)
      end

      def base_query(query_map = {}, filter_map = {})
        {
            page:     @page,
            start:    @start,
            rows:     @page_size,
            fq:       @facets.query(filter_map, (@focus&.value_map) || {}, @focus, self),
            per_page: @page_size
        }
      end

      # Query derived from pride-based parser
      def tree_query(query_map = {}, filter_map = {})
        base_query(query_map, filter_map).merge({
                                                    q: @tree.query(query_map),
                                                }).merge(@tree.params(query_map)).tap do |ret|
          if ret[:q].match(/ (AND|OR|NOT) /)
            ret[:q] = '+(' + ret[:q] + ')'
          end
        end
      end

      def query(query_map = {}, filter_map = {})
        if @is_new_parser && @psearch
          new_parser_query(query_map, filter_map)
        else
          tree_query(query_map, filter_map)
        end
      end

      def facets
        @facets
      end

      def spectrum
        ret = {
            uid:        @uid,
            start:      @start,
            count:      @count,
            field_tree: @tree.spectrum,
            facets:     @facets.spectrum,
            sort:       @sort,
            settings:   @settings
        }
        if @request_id
          ret.merge(request_id: @request_id)
        else
          ret
        end
      end

      def empty?
        @data.nil?
      end

      def build_psearch(focus = @focus)
        if empty?
          return MLibrarySearchParser::Search.new(
            '',
            {'search_fields' => {'' => nil}}
          )
        end
        @builder = MLibrarySearchParser::SearchBuilder.new(focus.raw_config)
        @builder.build(@data['raw_query'])
      end

      private

      def bad_request(message)
        raise ActionController::BadRequest.new('input', Exception.new(message))
      end

      def validate!
        bad_request 'uid is required' if @uid.nil?
        bad_request 'start must be >= 0' if @start < 0
        bad_request 'count must be >= 0' if @count < 0
        bad_request @tree.error unless @tree.valid?
        # TODO:
        # raise ActionController::BadRequest.new("input", @facets) unless @facets.valid?
        # bad_request "No sort specified" if @sort.nil?
      end
    end
  end
end
