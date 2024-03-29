module Spectrum
  module Config
    class SpecifiedSearchMetadataComponent < MetadataComponent
      type 'specified_search'

      attr_accessor :name, :variant, :scope, :text_field, :value_field

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.text_field = config['text_field']
        self.value_field = config['value_field']
      end

      def resolve_value(item, uid)
        return nil unless item.respond_to?(:find)
        (item.find {|attr| attr[:uid] == uid} || {})[:value]
      end

      def resolve_description(data)
        [data].flatten(1).map { |item|
          text = resolve_value(item, text_field)
          value = resolve_value(item, value_field)
          if text && value
            {
              text: text,
              search: {
                type: 'specified',
                value: value,
              }
            }
          else
            nil
          end
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
