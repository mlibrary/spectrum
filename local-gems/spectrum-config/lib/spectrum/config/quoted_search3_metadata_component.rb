module Spectrum
  module Config
    # This is used for Subjects not in subject browse. The data to be
    # transformed is an array of subject strings
    class QuotedSearch3MetadataComponent < MetadataComponent
      type "quoted_search3"

      attr_accessor :name, :variant, :scope, :text_field, :value_field

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.scope = config["scope"]
        self.variant = config["variant"]
      end

      def resolve_value(item)
        item.split("--").map { |x| x.strip }.join(" ")
      end

      def resolve_description(data)
        [data].flatten(1).map { |item|
          text = item.to_s
          value = resolve_value(text)
          if text && value
            {
              text: text,
              search: {
                type: variant,
                scope: scope,
                value: '"' + value.to_s.delete('"') + '"'
              }
            }
          end
        }.compact
      end

      def resolve(data)
        return nil if data.class != Array
        description = resolve_description(data)
        return nil if description.empty?
        {
          term: name,
          termPlural: name.pluralize,
          description: description
        }
      end
    end
  end
end
