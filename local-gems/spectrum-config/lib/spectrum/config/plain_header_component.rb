module Spectrum
  module Config
    class PlainHeaderComponent < HeaderComponent
      type 'plain'

      attr_accessor :append, :modifier

      def initialize(region, config)
        self.region = region
        self.append = config['append'] || ''
        self.modifier = config['modifier']
      end

      def get_description(data)
        [data].flatten(1).map do |item|
          item = item.to_s
          if item.empty?
            nil
          else
            ret = {text: item + append}
            ret[:modifier] = modifier if modifier
            ret
          end
        end.compact
      end

    end
  end
end
