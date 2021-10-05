module Spectrum
  module Config
    class PlainMetadataComponent < MetadataComponent
      type 'plain'

      def initialize(name, config)
        self.name = name
      end

      def get_description(data)
        [data].flatten(1).map do |item|
          item = item.to_s
          if item.empty?
            nil
          else
            {text: item}
          end
        end.compact
      end

      def resolve(data)
        return data if Hash === data && data[:term] && data[:description]
        description = get_description(data)
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
