# frozen_string_literal: true

require 'execjs'

module Spectrum
  module Request
    class Ids

      UNDERSCORE = '/tmp/search/node_modules/underscore/underscore.js'
      PRIDE = '/tmp/search/node_modules/pride/pride.execjs.js'
      PARSER  = 'Pride.Parser.parse'
      SOLR_URL = 'http://solr-vufind:8026/solr/biblio/'

      attr_reader :uri

      def initialize(req)
        underscore = IO.read(Rails.root.to_path + UNDERSCORE)
        pride = IO.read(Rails.root.to_path + PRIDE)
        context = ExecJS.compile(underscore + pride)

        raw_query = req.params[:query].to_s

        begin
          if raw_query.empty? || raw_query == '*'
            query = {}
          else
            query = context.call(PARSER, raw_query)
          end
        rescue
          query = context.call(PARSER, '"' + raw_query.gsub(/"/, '') + '"')
        end

        facets = req.params.map do |k,v|
          k.start_with?('filter.') ? [k[7..k.length], v] : nil
        end.compact.to_h

        if req.params[:library] && req.params[:library] != 'All Libraries'
          facets['institution'] = req.params[:library]
        end

        focus = Spectrum::Json.foci[req.params[:focus]]
        source = Spectrum::Json.sources[req.params[:source]]

        data = {
          'field_tree' => query,
          'facets' => facets,
          'uid' => focus.id,
        }

        request = Spectrum::Request::DataStore.new(data, focus)
        engine = source.engine(focus, request)
        solr_url = engine.instance_eval { @solr.uri.to_s }
        solr_params = engine.search.params.reject do |key, _|
          ['facet', 'facet.field'].include?(key)
        end.merge(
          'start' => 0,
          'rows' => 100000,
          'ps' => 0,
          'wt' => 'json',
          'json.nl' => 'arrarr',
          'fl' => 'id'
        )

        @uri = SOLR_URL + 'select' + '?' + URI.encode_www_form(solr_params)
      end
    end
  end
end
