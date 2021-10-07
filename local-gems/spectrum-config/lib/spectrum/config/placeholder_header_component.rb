module Spectrum
  module Config
    class PlaceholderHeaderComponent < HeaderComponent
      type 'placeholder'

      def initialize(region, config)
        self.region = region
      end

      def get_description(data)
        [data].flatten(1).map do |item|
          item = item.to_s
          if item.empty?
            nil
          else
            {placeholder: item}
          end
        end.compact
      end

    end
  end
end
