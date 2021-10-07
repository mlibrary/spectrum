module Spectrum
  module Config
    class HeaderComponent
      class << self
        def new(region, config)
          klass = get_type(config)
          return klass.new(region, config) if klass
          obj = allocate
          obj.send(:initialize, region, config)
          obj
        end

        def inherited(base)
          registry << base
        end

        def type(t = nil)
          @type = t if t
          @type
        end

        def get_type(config)
          return nil unless config&.respond_to?(:[])
          return nil unless config['type']
          registry.find {|item| item.type == config['type'] }
        end

        def registry
          @registry ||= []
        end
      end

      attr_accessor :region, :config

      def initialize(_, _)
      end

      def resolve(data)
        return data if Hash === data && data[:region] && data[:description]
        description = get_description(data)
        return nil if description.nil? || description.empty?

        {
          region: region,
          description: description,
        }
      end

      def get_description(_)
        nil
      end

      def icons(_)
        nil
      end

    end
  end
end

