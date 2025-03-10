module Spectrum
  module SearchEngines
    module Primo
      class Response
        attr_accessor :info, :highlights, :docs, :timelog, :facets

        def self.for_json(json)
          begin
            new(
              info: Info.for_json(json['info']),
              highlights: Highlights.for_json(json['highlights']),
              docs: Docs.for_json(json['docs'], json.dig("info", "first").to_i),
              timelog: Timelog.for_json(json['timelog']),
              facets: Facets.for_json(json['facets'])
            )
          rescue MultiXml::ParseError => e
            for_nothing
          end
        end

        def self.for_nothing
          new(
            info: Info.for_json(nil),
            highlights: Highlights.for_json(nil),
            docs: Docs.for_json([], 0),
            timelog: Timelog.for_json(nil),
            facets: Facets.for_json([])
          )
        end

        def with_libkey(config)
          return self if config.empty? ||
            config['library_id'].empty? ||
            config['host'].empty? ||
            config['key'].empty?
          @docs.each do |doc|
            doc.libkey = LibKey.for_data(config, 'pmid', doc['pmid']&.first) ||
              LibKey.for_data(config, 'doi', doc['doi']&.first) ||
              LibKey.for_nothing
          end
          self
        end

        def initialize(info:, highlights:, docs:, timelog:, facets:)
          @info = info
          @highlights = highlights
          @docs = docs
          @timelog = timelog
          @facets = facets
        end

        def total_items
          @info.total
        end

        def total_items_magnitude
          Math.log10(total_items).ceil
        end

        def length
          @docs.length
        end

        def first
          @docs.first
        end

        def map
          @docs.map do |doc|
            yield doc
          end
        end
      end
    end
  end
end

