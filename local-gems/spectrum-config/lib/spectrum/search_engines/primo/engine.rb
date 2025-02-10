module Spectrum
  module SearchEngines
    module Primo
      class Engine
        attr_accessor :key, :host, :tab, :scope, :view, :libkey, :params

        def initialize(
          key:,
          host:,
          tab: 'default_tab',
          scope: 'default_scope',
          view: 'Auto1',
          libkey:,
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

          response = nil
          primo_duration = Benchmark.realtime do
            response = Response.for_json(HTTParty.get(url))
          end

          libkey_duration = Benchmark.realtime do
            @results = response.with_libkey(libkey)
          end
          Metrics(:api_response_duration_seconds) do |metric|
            metric.observe(primo_duration, labels: {source: 'primo'})
            metric.observe(libkey_duration, labels: {source: 'libkey'})
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
            vid: view,
          }).to_query
        end
      end
    end
  end
end
