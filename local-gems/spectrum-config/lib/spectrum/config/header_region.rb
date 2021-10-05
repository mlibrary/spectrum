module Spectrum
  module Config
    class HeaderRegion

      def initialize(config)
        if config.is_a?(Hash)
          @region, component_config = config.first
        end

        @header_component = HeaderComponent.new(@region, component_config)
      end

      def resolve(data)
        return nil if @header_component.nil?
        @header_component.resolve(data)
      end

    end
  end
end
