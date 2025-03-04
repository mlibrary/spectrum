module Spectrum
  module SearchEngines
    module Primo
      class Engine
        attr_accessor :key, :host, :tab, :scope, :view, :libkey, :params

        def initialize(
          key:,
          host:,
          libkey:, tab: "default_tab",
          scope: "default_scope",
          view: "Auto1",
          params: {}
        )
          @key = key
          @host = host
          @tab = tab
          @scope = scope
          @view = view
          @libkey = libkey
          @params = params
          @results = nil
          if defined?(Rails) && Rails.respond_to?(:logger)
            @logger = Rails.logger
          end
        end

        def results
          search
        end

        def total_items
          results.total_items
        end

        def search
          return @results if @results
          @logger&.info { url }
          primo_response = nil
          ActiveSupport::Notifications.instrument("primo_search.spectrum_search_engine_primo", source_id: "primo", params: params, url: url) do
            primo_response = begin
              Response.for_json(HTTParty.get(url))
            rescue EOFError, Errno::ECONNRESET => e
              ActiveSupport::Notifications.instrument("primo_exception.spectrum_search_engine_primo", source_id: "primo", params: params, url: url, exception: e)
              Response.for_nothing
            end
          end
          ActiveSupport::Notifications.instrument("libkey_search.spectrum_search_engine_primo", source_id: "libkey", params: params, url: url) do
            @results = primo_response.with_libkey(libkey)
          end
          ActiveSupport::Notifications.instrument("primo_results.spectrum_search_engine_primo", results: @results) do
          end
          @results
        end

        def url
          "https://#{host}/primo/v1/search?" + query
        end

        def query
          params.merge({
            apikey: key,
            tab: tab,
            scope: scope,
            vid: view
          }).to_query
        end
      end
    end
  end
end
