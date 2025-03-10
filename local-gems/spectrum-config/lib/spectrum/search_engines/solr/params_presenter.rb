module Spectrum
  module SearchEngines
    class Solr
      class ParamsPresenter
        def initialize(params)
          @keyword_count = 0
          @has_booleans = false
          @has_quotes = false
          @requested_records = 0
          return unless params
          @requested_records = params[:rows]
          ts = params.keys.select { |key| %r{^t\d+}.match?(key) }.map {|key| params[key]}.flatten.join(" ")
          if ts.empty?
            @keyword_count = params[:q].split(" ").length
            @has_quotes = params[:q].include?('"')
          else
            @keyword_count = ts.split(" ").length
            @has_quotes = ts.include?('"')
          end

          qs = params.keys.select { |key| %r{^q\d+}.match?(key) }.map {|key| params[key]}
          @has_booleans = ["AND", "OR", "NOT"].any? {|boolean| qs.any? {|q| q.include?(boolean)}}

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
