module Spectrum
  module Config
    class SearchBrowseMetadataComponent < MetadataComponent
      type 'search_browse'

      attr_accessor :name, :search_variant, :search_scope, :text_field,
                    :value_field, :quoted_search, :quoted_browse,
                    :browse_variant, :browse_text

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.browse_variant = config['browse_variant']
        self.browse_text = config['browse_text']
        self.quoted_browse = config['quoted_browse']
        self.search_scope = config['search_scope']
        self.search_variant = config['search_variant']
        self.text_field = config['text_field']
        self.value_field = config['value_field']
        self.quoted_search = config['quoted_search']
      end

      def resolve_value(item, uid)
        return nil unless item.respond_to?(:find)
        (item.find {|attr| attr[:uid] == uid} || {})[:value]
      end

      def resolve_description(data)
        [data].flatten(1).map { |item|
          text = resolve_value(item, text_field)
          value = resolve_value(item, value_field)
          quoted_value = '"' + value.to_s.gsub(/"/, '') + '"'
          if text && value
            {
              text: text,
              search: {
                type: search_variant,
                scope: search_scope,
                value: quoted_search ? quoted_value : value,
              },
              browse: {
                text: browse_text,
                type: browse_variant,
                value: quoted_browse ? quoted_value : value,
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
