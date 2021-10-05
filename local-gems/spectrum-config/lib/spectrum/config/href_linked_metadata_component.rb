module Spectrum
  module Config
    class HrefLinkedMetadataComponent < MetadataComponent
      type 'href_linked'

      attr_accessor :href_field, :text_field

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.href_field = config['href_field'] || 'href'
        self.text_field = config['text_field'] || 'text'
      end

      def resolve(data)
        return nil if data.nil?
        description = [data].flatten(1).map { |item|
          if item.respond_to?(:[])
            {text: item[text_field], href: item[href_field]}.compact
          else
            nil
          end
        }.compact
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
