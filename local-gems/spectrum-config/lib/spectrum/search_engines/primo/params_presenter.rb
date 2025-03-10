module Spectrum
  module SearchEngines
    module Primo
      class ParamsPresenter

        def initialize(params)
          @keyword_count = 0
          @has_booleans = false
          @has_quotes = false
          @requested_records = 0
          return unless params
          if params[:limit]
            @requested_records = params[:limit]
          end
          return unless params[:q]
          components = params[:q].split(",")
          i = 2
          while i < components.length
            @has_quotes = true if components[i].include?('"')
            @keyword_count += components[i].split(" ").compact.length
            i += 4
          end
          @has_booleans = components.length > 4
        end

        def keyword_count
          @keyword_count > 5 ? "6+" : @keyword_count
        end

        def requested_records
          @requested_records
        end

        def has_booleans?
          @has_booleans
        end

        def has_quotes?
          @has_quotes
        end
      end
    end
  end
end
