module Spectrum
  module Config
    class QuotedSearch1MetadataComponent < MetadataComponent
      type 'quoted_search1'

      attr_accessor :name, :variant, :scope

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.scope = config['scope']
        self.variant = config['variant']
      end

      def resolve_description(data)
        [data].flatten(1).map { |item|
          {
            text: item,
            search: {
              type: variant,
              scope: scope,
              value: '"' + item.to_s.gsub(/"/, '') + '"',
            }
          }
        }.compact
      end

      def resolve(data)
        return nil if data.nil?
        description = resolve_description(data)
        return nil if description.empty?
        {
          term: name,
          termPlural: name.pluralize,
          description: description,
        }
      end
    end
  end
end
