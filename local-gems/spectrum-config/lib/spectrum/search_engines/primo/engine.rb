module Spectrum
  module SearchEngines
    module Primo
      class Engine
        attr_accessor :key, :host, :tab, :scope, :view, :params

        def initialize(
          key:,
          host:,
          tab: 'default_tab',
          scope: 'default_scope',
          view: 'Auto1',
          params: {}
        )
          @key = key
          @host = host
          @tab = tab
          @scope = scope
          @view = view
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
          @logger&.info { url }
          @results ||= Response.for_json(HTTParty.get(url))
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
