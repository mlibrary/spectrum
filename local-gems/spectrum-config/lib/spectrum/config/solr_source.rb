# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class SolrSource < BaseSource
      attr_accessor :truncate
      def initialize(args)
        super
        @truncate = args['truncate']
      end

      def is_solr?
        true
      end

      def truncate?
        @truncate || false
      end

      def engine(focus, request, controller = nil)
        p = params(focus, request, controller)
        p[:config] = ::Blacklight::Configuration.new do |config|
          focus.configure_blacklight(config, request)
        end
        p[:fq] += focus.filters
        p[:sort] = focus.get_sorts(request) if request.can_sort?
        p[:config].default_solr_params = focus.solr_params
        p[:qt] = focus.solr_params['qt'] if focus.solr_params['qt']
        p[:qf] = focus.solr_params['qf'] if focus.solr_params['qf']
        p[:pf] = focus.solr_params['pf'] if focus.solr_params['pf']
        p[:mm] = focus.solr_params['mm'] if focus.solr_params['mm']
        p[:tie] = focus.solr_params['tie'] if focus.solr_params['tie']
        engine = Spectrum::SearchEngines::Solr.new(p)
        engine.results.slice(*request.slice)
        engine
      end

      def params(focus, request, controller = nil)
        new_params = super
        @conditionals.each_pair do |condition, fq|
          if request.respond_to?(condition) && request.send(condition)
            new_params[:fq] << fq
          end
        end
        new_params
      end
    end
  end
end
