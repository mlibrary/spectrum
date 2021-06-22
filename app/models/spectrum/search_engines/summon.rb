
module Spectrum
  module SearchEngines
    class Summon
      include ActionView::Helpers::NumberHelper
      include Rails.application.routes.url_helpers
      Rails.application.routes.default_url_options = ActionMailer::Base.default_url_options
      MAX_PAGE_SIZE = 50

      # These are ALWAYS in effect for Summon API queries
      # s.ff - how many options to retrieve for each filter field
      SUMMON_FIXED_PARAMS = {
        'spellcheck' => true,
        's.ff' => [
          'ContentType,and,1,100',
          'SubjectTerms,and,1,100',
          'Language,and,1,100',
          'IsScholarly,and,1,2',
          'IsFulltext,and,1,2',
          'IsOpenAccess,and,1,2'
        ],
        's.rff' => ['PublicationDate,1901:1910,1911:1920,1921:1930,1931:1940,1941:1950,1951:1960,1961:1970,1971:1980,1981:1990,1991:2000,2001:2010,2011:2020'],
      }.freeze

      # These source-specific params are ONLY FOR NEW SEARCHES
      # s.ho=<boolean>     Holdings Only Parameter, a.k.a., "Columbia's collection only"
      SUMMON_DEFAULT_PARAMS = {

        'newspapers' =>  {
          's.ho' => 't',
          # 's.cmd' => 'addFacetValueFilters(ContentType, Newspaper Article)'
          's.fvf' => ['ContentType, Newspaper Article']
        }.freeze,

        'articles' =>  {
          's.ho' => 't',
          # 's.cmd' => 'addFacetValueFilters(ContentType, Newspaper Article:t)'
          's.fvf' => ['ContentType, Newspaper Article,t']
        }.freeze,

        'ebooks' => {
          's.ho' => 't',
          's.cmd' => 'addFacetValueFilters(IsFulltext, true)',
          's.fvf' => ['ContentType,eBook']
        }.freeze,

        'dissertations' => {
          's.ho' => 't',
          's.fvf' => ['ContentType,Dissertation']
        }.freeze
      }.freeze

      attr_reader :source, :errors, :search
      attr_accessor :params

      # initialize() performs the actual API search, and
      # returns @search - a filled-in search structure, including query results.
      # input "options" are the CGI-param inputs, while
      # @params is a built-up parameters hash to pass to the Summon API
      def initialize(options = {})
        # Rails.logger.debug "initialize() options=#{options.inspect}"
        @source = options.delete('source') || options.delete(:source)
        @params = {}

        # These sources only come from bento-box aggregate searches, so enforce
        # the source-specific params without requires 'new_search' CGI param
        if @source && (@source == 'ebooks' || @source == 'dissertations') && SUMMON_DEFAULT_PARAMS[@source]
          @params = SUMMON_DEFAULT_PARAMS[@source].dup

        # Otherwise, when source is Articles or Newspapers, we set source-specific default
        # params only for new searches.  Subsequent searches may change these values.
        elsif @source && options.delete('new_search') && SUMMON_DEFAULT_PARAMS[@source]
          @params = SUMMON_DEFAULT_PARAMS[@source].dup
        end

        # These are ALWAYS in effect for Summon API queries
        @params.merge!(SUMMON_FIXED_PARAMS)

        @search_url = options.delete('search_url')

        @search_field = options.delete('search_field') || ''

        @debug_mode = options.delete('debug_mode') || false
        @debug_entries = Hash.arbitrary_depth

        # Map the 'q' CGI param to a 's.q' internal Summon param
        @params['s.q'] = options.delete(:q)
        @params['s.hl'] = 'false'

        @params.merge!(options)
        @params.delete('utf8')

        # assure these are empty strings, if not passed via CGI params
        @params['s.q']   ||= ''
        @params['s.cmd'] ||= ''
        @params['s.fq']  ||= ''

        # This allows authenticated searches within Summon.
        #   http://api.summon.serialssolutions.com/help/api/search/parameters/role
        # It's set to 'authenticated' if we've logged in or are on-campus,
        # but that's done in SpectrumController, since this module
        # doesn't have access to necessary Application variables.
        @params['s.role'] ||= ''

        # process any Filter Query - turn Rails hash into array of
        # key:value pairs for feeding to the Summon API
        # (see inverse transform in SpectrumController#search)
        #  BEFORE: params[s.fq]={"AuthorCombined"=>"eric foner"}
        #  AFTER:  params[s.fq]="AuthorCombined:eric foner"
        if @params['s.fq'].kind_of?(Hash)
          new_fq = []
          @params['s.fq'].each_pair do |name, value|
            new_fq << "#{name}:#{value}" unless value.to_s.empty?
          end
          @params['s.fq'] = new_fq
        end

        @errors = nil
# raise

        if @params[:per_page] and !@params['s.ps']
          @params['s.ps'] = @params.delete(:per_page)
        end

        if @params[:page] and !@params['s.pn']
          @params['s.pn'] = @params.delete(:page)
        end

        if  !@params['s.ps'] || @params['s.ps'] > MAX_PAGE_SIZE
          @params['s.ps'] = MAX_PAGE_SIZE
        end

        @params['s.ho'] = options.delete('s.ho')

        begin
          # do_benchmarking = false
          # if do_benchmarking
          #   require 'summon/benchmark'
          #   bench = ::Summon::Benchmark.new()
          #   @config.merge!( :benchmark => bench)
          # end

          Rails.logger.debug "[Spectrum][Summon] config: #{@config}"
          Rails.logger.debug "[Spectrum][Summon] params: #{@params}"
          @service = ::Summon::Service.new(@source)

          ### THIS is the actual call to the Summon service to do the search
          @search = @service.search(@params)

          # Inject the 1-offset position into each document in the results.
          starting_position = (@search.query.page_number - 1) * @search.query.page_size + 1
          @search.documents.each.with_index(starting_position) do |doc, index|
            doc.src['position'] = index
          end

          # if do_benchmarking
          #   bench.output
          # end

        rescue => ex
          # We're getting 500 errors here - is that an internal server error
          # on the Summon side of things?  Need to look into this more.
          Rails.logger.error "#{self.class}##{__method__} error: #{ex}"
          @errors = ex.message
        end
      end

      FACET_ORDER = %w(ContentType_mfacet SubjectTerms_mfacet Language_s)

      def facets
        @search.facets.sort_by { |facet| (ind = FACET_ORDER.index(facet.field_name)) ? ind : 999 }
      end

      # The "pre-facet-options" are the four checkboxes which precede the facets.
      # Return array of ad-hoc structures, parsed by summon's facets partial
      def pre_facet_options_with_links
        facet_options = []

        # first checkbox, "Full text online only"
        is_full_text = facet_value('IsFulltext') == 'true'
        is_full_cmd = !is_full_text ? 'addFacetValueFilters(IsFulltext, true)' : 'removeFacetValueFilter(IsFulltext,true)'
        facet_options << {
          style: :checkbox,
          value: is_full_text,
          link: by_source_search_cmd(is_full_cmd),
          name: 'Full text online only'
        }

        # second checkbox, "Scholarly publications only"
        is_scholarly = facet_value('IsScholarly') == 'true'
        is_scholarly_cmd = !is_scholarly ? 'addFacetValueFilters(IsScholarly, true)' : 'removeFacetValueFilter(IsScholarly,true)'
        facet_options << {
          style: :checkbox,
          value: is_scholarly,
          link: by_source_search_cmd(is_scholarly_cmd),
          name: 'Scholarly publications only'
        }

        # third checkbox, "Exclude Newspaper Articles"
        exclude_newspapers = @search.query.facet_value_filters.any? do |fvf|
          fvf.field_name == 'ContentType' &&
          fvf.value == 'Newspaper Article' &&
          fvf.negated?
        end
        exclude_cmd = !exclude_newspapers ?
              'addFacetValueFilters(ContentType, Newspaper Article:t)' :
              'removeFacetValueFilter(ContentType, Newspaper Article)'
        facet_options << {
          style: :checkbox,
          value: exclude_newspapers,
          link: by_source_search_cmd(exclude_cmd),
          name: 'Exclude Newspaper Articles'
        }

        # fourth checkbox, "Columbia's collection only"
        all_holdings_only = @search.query.holdings_only_enabled == true
        facet_options << {
          style: :checkbox,
          value: all_holdings_only,
          link: by_source_search_cmd("setHoldingsOnly(#{!all_holdings_only})"),
          name: "Columbia's collection only"
        }

        facet_options
      end

      # unused?
      # def newspapers_excluded?()
      #   @search.query.facet_value_filters.any? { |fvf|
      #     fvf.field_name == "ContentType" &&
      #     fvf.value == "Newspaper Article" &&
      #     fvf.negated? }
      # end

      def results
        documents || []
      end

      def search_path
        @search_url || by_source_search_link(@params)
      end

      def current_sort_name
        if @search.query.sort.nil?
          'Relevance'
        elsif @search.query.sort.field_name == 'PublicationDate'
          if @search.query.sort.sort_order == 'desc'
            'Published Latest'
          else
            'Published Earliest'
          end
        end
      end

      # The "constraints" are the displayed, cancelable, search params
      # (currently applied queries, facets, etc.)
      # Return an array of ad-hoc structures, parsed by summon's constraints partial
      def constraints_with_links
        constraints = []
# raise
        # add in the basic search query
        @search.query.text_queries.each do |q|
          constraints << [q['textQuery'], by_source_search_cmd(q['removeCommand'])]
        end

        # add in "filter queries" - each advanced search field
        @search.query.text_filters.each do |q|
          filter_text = q['textFilter'].to_s.
              # strip "Combined" off the back of labels (TitleCombined --> Title)
              sub(/^([^\:]+)Combined:/, '\1:').
              # NEXT-581 - articles search by publication title
              # search for embedded capitals, insert a space (PublicationTitle --> Publication Title)
              sub(/([a-z])([A-Z])/, '\1 \2').
              sub(':', ': ')
          constraints << [filter_text, by_source_search_cmd(q['removeCommand'])]
        end

        # add in Facet limits
        @search.query.facet_value_filters.each do |fvf|
          unless fvf.field_name.titleize.in?('Is Scholarly', 'Is Full Text')
            facet_text = "#{fvf.negated? ? "Not " : ""}#{fvf.field_name.titleize}: #{fvf.value}"
            constraints << [facet_text, by_source_search_cmd(fvf.remove_command)]
          end
        end

        # add in Range Filters
        @search.query.range_filters.each do |rf|
          facet_text = "#{rf.field_name.titleize}: #{rf.range.min_value}-#{rf.range.max_value}"
          constraints << [facet_text, by_source_search_cmd(rf.remove_command)]
        end

        constraints
      end

      # List of sort options, turned into a drop-down in summon's sorting/paging partial
      def sorts_with_links
        [
          [by_source_search_cmd('setSortByRelevancy()'), 'Relevance'],
          [by_source_search_cmd('setSort(PublicationDate:desc)'), 'Published Latest'],
          [by_source_search_cmd('setSort(PublicationDate:asc)'), 'Published Earliest']
        ]
      end

      # List of paging options, turned into a drop-down in summon's sorting/paging partial
      def page_size_with_links
        # [10,20,50,100].collect do |page_size|
        [10, 25, 50].map do |per_page|
          # No, don't do a COMMAND...
          # [by_source_search_cmd("setPageSize(#{page_size})"), page_size]
          # Just reset s.ps, it's much more transparent...
          [set_page_size(per_page), per_page]
        end
      end

      def successful?
        @errors.nil?
      end

      def documents
        if @search
          @search.documents
        else
          []
        end
      end

      # def start_over_link
      #   by_source_search_link('new_search' => true)
      # end

      def previous_page?
        current_page > 1 && total_pages > 1
      end

      def previous_page_path
        set_page_path(current_page - 1)
      end

      def next_page?
        # Why was this 20-page limit in effect?
        # total_pages > current_page && 20 > current_page

        # # Summon API hard limit: only first 500 items will ever be returned.
        # # Allow a next-page link if it's max item will be within this bound.
        # page_size * (current_page + 1) <= 500

        # NEXT-1078 - CLIO Articles limit 500 records, Summon 1,000
        # Update - Maximum supported returned results set size is now 1000.
        page_size * (current_page + 1) <= 1000
      end

      def next_page_path
        set_page_path(current_page + 1)
      end

      def set_page_path(page_num)
        by_source_search_modify('s.pn' => [total_pages, [page_num, 1].max].min)
      end

      def set_page_size(per_page)
        by_source_search_modify('s.ps' => [(per_page || 10), 50].min)
      end

      def total_items
        # handle error condition when @search object is nil
        if @search
          @search.record_count
        else
          # I don't need to log this - I'm reliably logging the search failure which
          # led to this condition.
          # Rails.logger.error "[Spectrum][Summon] total_items called on null @search"
          0
        end
      end

      def start_item
        (page_size * (current_page - 1)) + 1
      end

      def end_item
        [start_item + page_size - 1, total_items].min
      end

      def total_pages
        @search.page_count
      end

      def current_page
        @search.query.page_number
      end

      def page_size
        @search.query.page_size.to_i
      end

      def by_source_search_cmd(cmdText)
        by_source_search_modify('s.cmd' => cmdText)
      end

      # Create a link based on the current @search query, but
      # modified by whatever's passed in (facets, checkboxes, sort, paging),
      # and by possible advanced-search indicator
      def by_source_search_modify(cmd = {})
        # start with the query, directly extracted from the Summon object
        # (which means "s.fq=AuthorCombined:eric+foner")
        # Rails.logger.debug  "SQ=[#{@search.query.to_hash.inspect}]"
        params = @search.query.to_hash
        # NEXT-903 - ALWAYS reset to seeing page number 1.
        # The only exception is the Next/Prev page links, which will
        # reset s.pn via the passed input param cmd, below
        params.merge!('s.pn' => 1)
        # merge in whatever new command overlays current summon state
        params.merge!(cmd)
        # raise
        # add-in our CLIO interface-level params
        params.merge!('form' => @params['form']) if @params['form']
        params.merge!('search_field' => @search_field) if @search_field
        params.merge!('q' => @params['q']) if @params['q']
        # pass along the built-up params to a source-specific URL builder
        by_source_search_link(params)
      end

      private

      def facet_value(field_name)
        fvf = @search.query.facet_value_filters.find { |x| x.field_name == field_name }
        fvf ? fvf.value : nil
      end

      def by_source_search_link(params = {})
        case @source
        when 'newspapers'
          newspapers_index_path(params)
        when 'articles'
          articles_index_path(params)
        else
          articles_index_path(params)
        end
      end
    end
  end
end
