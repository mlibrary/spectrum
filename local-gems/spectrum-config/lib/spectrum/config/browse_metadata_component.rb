module Spectrum
  module Config
    class BrowseMetadataComponent < MetadataComponent
      type 'browse'

      attr_accessor :name, :variant

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.variant = config['variant']
      end

      def resolve_description(data)
        [data].flatten(1).map { |item|
          {
            text: item,
            browse: {
              type: variant,
              value: item,
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
