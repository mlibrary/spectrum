# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class SummonSource < BaseSource
      attr_accessor :access_id, :client_key, :secret_key, :log, :benchmark,
                    :transport, :session_id
      def initialize(args)
        super
        @log        = args['log']        || nil
        @benchmark  = args['benchmark']  || nil
        @transport  = args['transport']  || nil
        @access_id  = args['access_id']  || nil
        @secret_key = args['secret_key'] || nil
        @client_key = args['client_key'] || nil
        @session_id = args['session_id'] || nil
      end

      def fetch_record(field, id, role = 'authenticated')
        engine = Spectrum::SearchEngines::Summon.new('s.fids' => id,
                                                     's.role' => role,
                                                     'source' => self,
                                                     source: self)
        return {} unless engine && engine.documents
        engine.documents.first || {}
      end

      def engine(focus, request, controller)
        Spectrum::SearchEngines::Summon.new(params(focus, request, controller))
      end

      def params(focus, request, controller = nil)
        new_params = super
        new_params.delete(:fq)

        new_params['s.fvf'] = request.fvf
        new_params['s.rff'] = request.rff
        new_params['s.rf']  = request.rf

        # The Summon API support authenticated or un-authenticated roles,
        # with Authenticated having access to more searchable metadata.
        # We're Authenticated if the user is on-campus, or has logged-in.
        new_params['s.role'] = 'authenticated' if request.authenticated?

        # items-per-page (summon page size, s.ps, aka 'rows') should be
        # a persisent browser setting
        if new_params['s.ps'] && (new_params['s.ps'].to_i > 1)
          # Store it, if passed
          # controller.set_browser_option('summon_per_page', new_params['s.ps'])
        end

        # Article searches within QuickSearch should act as New searches
        # new_params['new_search'] = 'true' if controller.active_source == 'quicksearch'
        # QuickSearch is only one of may possible Aggregates - so maybe this instead?
        # params['new_search'] = 'true' if @search_style == 'aggregate'

        # If we're coming from the LWeb Search Widget - or any other external
        # source - mark it as a New Search for the Summon search engine.
        # (fixes NEXT-948 Article searches from LWeb do not exclude newspapers)
        # clios = ['http://clio', 'https://clio', 'http://localhost', 'https://localhost']
        # params['new_search'] = true unless request.referrer && clios.any? do |prefix|
        # request.referrer.starts_with? prefix
        # end
        new_params['new_search'] = true

        # New approach, 5/14 - params will always be "q".
        # "s.q" is internal only to the Summon controller logic
        if new_params['s.q']
          # s.q ovewrites q, unless 'q' is given independently
          new_params['q'] = new_params['s.q'] unless new_params['q']
          new_params.delete('s.q')
        end
        new_params['s.sort'] = (focus.sorts.values.find { |sort| sort.uid == request.sort } || focus.default_sort).value

        #   # LibraryWeb QuickSearch will pass us "search_field=all_fields",
        #   # which means to do a Summon search against 's.q'
        if new_params['q'] && new_params['search_field'] && (new_params['search_field'] != 'all_fields')
          hash = Rack::Utils.parse_nested_query("#{new_params['search_field']}=#{new_params['q']}")
          new_params.merge! hash
        end

        if new_params['pub_date']
          new_params['s.cmd'] = "setRangeFilter(PublicationDate,#{new_params['pub_date']['min_value']}:#{new_params['pub_date']['max_value']})"
        end

        new_params['s.ho'] = request.holdings_only? ? 'true' : 'false'

        new_params['s.fvf'] << 'IsScholarly,true' if request.is_scholarly?
        new_params['s.fvf'] << 'IsOpenAccess,true' if request.is_open_access?

        if request.exclude_newspapers?
          new_params['s.fvf'] << 'ContentType,Newspaper\ Article,true'
        end

        new_params['s.fvf'] << 'IsFulltext,true' if request.available_online?

        new_params['s.bookMark'] = request.book_mark if request.book_mark?

        new_params
      end
    end
  end
end
