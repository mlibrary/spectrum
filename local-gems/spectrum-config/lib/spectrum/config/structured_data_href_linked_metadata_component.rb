module Spectrum
  module Config
    class StructuredDataHrefLinkedMetadataComponent < MetadataComponent
      type 'structured_data_href_linked'

      attr_accessor :href_field, :text_field

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.href_field = config['href_field'] || 'href'
        self.text_field = config['text_field'] || 'text'
      end

      def resolve(data)
        return nil if data.nil?
        description = [data].flatten(1).map { |row|
          text_value = (row.find {|field| field["uid"] == text_field} || {})["value"]
          href_value = (row.find {|field| field["uid"] == href_field} || {})["value"]
          if text_value && href_value
            {text: text_value, href: href_value}.compact
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
