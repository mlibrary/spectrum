module Spectrum
  module SearchEngines
    module Primo
      class Response
        attr_accessor :info, :highlights, :docs, :timelog, :facets

        def self.for_json(json)
          return self.new(
            info: Info.for_json(json['info']),
            highlights: Highlights.for_json(json['highlights']),
            docs: Docs.for_json(json['docs'], json['info']['first'].to_i),
            timelog: Timelog.for_json(json['timelog']),
            facets: Facets.for_json(json['facets'])
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

