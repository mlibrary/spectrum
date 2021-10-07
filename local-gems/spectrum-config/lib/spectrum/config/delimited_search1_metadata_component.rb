module Spectrum
  module Config
    class DelimitedSearch1MetadataComponent < MetadataComponent
      type 'delimited_search1'

      attr_accessor :name, :scope, :variant, :delimiter

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.scope = config['scope']
        self.variant = config['variant']
        self.delimiter = config['delimiter']
      end

      def resolve_description(data)
        [data].flatten(1).map do |list|
          list.to_s.split(delimiter).reject(&:empty?).map do |item|
            {
              text: item,
              search: {
                type: variant,
                scope: scope,
                value: item,
              }
            }
          end
        end.compact
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
