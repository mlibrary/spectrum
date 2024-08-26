module Spectrum
  module Config
    # This is used for subject fields that have links to subject browse.
    class SearchBrowse2MetadataComponent < MetadataComponent
      type "search_browse2"

      attr_accessor :name, :search_variant, :search_scope,
        :quoted_search, :quoted_browse, :browse_variant, :browse_text

      def initialize(name, config)
        config ||= {}
        self.name = name
        self.browse_variant = config["browse_variant"]
        self.browse_text = config["browse_text"]
        self.quoted_browse = config["quoted_browse"]
        self.search_scope = config["search_scope"]
        self.search_variant = config["search_variant"]
        self.quoted_search = config["quoted_search"]
      end

      def resolve_value(item)
        item.split("--").map { |x| x.strip }.join(" ")
      end

      def resolve_description(data)
        [data].flatten(1).map { |item|
          text = item.to_s

          value = resolve_value(item)
          quoted_value = '"' + value.to_s.delete('"') + '"'
          if text && value
            {
              text: text,
              search: {
                type: search_variant,
                scope: search_scope,
                value: quoted_search ? quoted_value : value
              },
              browse: {
                text: browse_text,
                type: browse_variant,
                value: quoted_browse ? quoted_value : value
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
