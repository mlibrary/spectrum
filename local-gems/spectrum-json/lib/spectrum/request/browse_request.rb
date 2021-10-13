# frozen_string_literal: true
require 'callnumber_collation'

module Spectrum
  module Request
    class BrowseRequest
      include Requesty

      def initialize(request = nil, focus = nil, sort_dir = nil)
        @request = request
        @focus = focus
        @data = get_data(@request)
        @messages = []
        @sort_dir = sort_dir
        if (@data)
          bad_request 'Request json did not validate' unless Spectrum::Json::Schema.validate(:request, @data)

          @uid        = @data['uid']
          @start      = @data['start'].to_i
          @count      = @data['count'].to_i
          @page       = @data['page']
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
          @browse_field = @data['browse_field']
          @search_field = if @browse_field == 'callnumber'
                              ENV['SPECTRUM_CALLNUMBER_BROWSE_FIELD']
                            end
        end
        @page = (@page_number || 0) + 1

        @start ||= 0
        @count ||= 0
        @slice ||= [0, @count]

        @tree      ||= Spectrum::FieldTree::Empty.new
        @facets    ||= Spectrum::FacetList.new(nil)
        @page_size ||= 0
      end

      def query(_query_map, _filter_map)
        if @browse_field == 'callnumber'
          call_number_browse_query
        end
      end

      def call_number_browse_query
        callnum = @data['raw_query']
        collation = CallnumberCollation::LC.new(callnum)
        collation_key = collation.collation_key

        if @sort_dir == :asc
          params = browse_query_following(collation_key)
        else
          params = browse_query_preceding(collation_key)
        end
        return params
      end

      def browse_query_preceding(term)
        {
            q:        "#{@browse_field}:*",
            page:     @page,
            start:    @start,
            rows:     @page_size,
            fq:       ["#{@search_field}:[* TO \"#{term}\"]"],
            per_page: @page_size,
            sort:     "#{@search_field} desc"
        }
      end

      def browse_query_following(term)
        {
            q:        "#{@browse_field}:*",
            page:     @page,
            start:    @start,
            rows:     @page_size,
            fq:       ["#{@search_field}:[\"#{term}\" TO *]"],
            per_page: @page_size,
            sort:     "#{@search_field} asc"
        }
      end

      def solr_params
        Hash.new
      end

      def facet_sort

      end

      def facet_limit

      end

      def facet_offset

      end

      def facet_uid

      end

      def search_only?
        false
      end

      def can_sort?
        # if this returns true we take sorts from the focus
        # but we know exactly how we want to sort here
        false
      end


    end
  end
end
