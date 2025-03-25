module Spectrum
  module SearchEngines
    class Solr
      attr_accessor :default_solr_params

      def initialize(original_options)
        @request = original_options.delete("request") || original_options.delete(:request) || fail("Must specify request")
        original_options.delete(:request)

        @source = original_options.delete("source") || original_options.delete(:source) || fail("Must specify source")
        original_options.delete(:source)

        @focus = original_options.delete("focus") || original_options.delete(:focus) || fail("Must specify focus")
        original_options.delete(:focus)

        options = original_options.to_hash.deep_clone

        @default_solr_params = options.delete("default_solr_params") || options.delete(:default_solr_params)

        @params = @default_solr_params.merge(options)
        @params.symbolize_keys!

        @solr = RSolr.connect(url: @source.url)

        @params.merge!(@focus.solr_field_list)
        @params.merge!(@focus.solr_facets(@request))

        @params[:qt] = "standard" unless @params[:qt] == "edismax" || @params[:qt] == "dismax"
        if @params[:q] == "*:*"
          remove_null_search_extraneous_parameters
        end

        @params[:qq] ||= '"' + RSolr.solr_escape(@params[:q]) + '"'

        duration = Benchmark.realtime do
          @response = begin Response.for(@solr.post("select", data: @params))
          rescue RSolr::Error::Http => e
            ActiveSupport::Notifications.instrument("rsolr_exception.spectrum_search_engine_solr", exception: e)
            Response.for_nothing
          end
        end
        ActiveSupport::Notifications.instrument(
          "solr_search.spectrum_search_engine_solr",
          source_id: @source.id,
          params: ParamsPresenter.new(@params),
          response: @response,
          duration: duration
        )
      end

      def total_items
        @response.total_items
      end

      def results
        @response
      end

      def search
        @response.raw
      end

      NULL_SEARCH_EXTRANEOUS_PARAMS = %w[
        boost
        bq
        pf2
        pf3
      ]
      # qf
      # pf
      # mm

      def remove_null_search_extraneous_parameters
        NULL_SEARCH_EXTRANEOUS_PARAMS.each do |f|
          @params.delete(f)
          @params.delete(f.to_sym)
        end
      end
    end
  end
end
