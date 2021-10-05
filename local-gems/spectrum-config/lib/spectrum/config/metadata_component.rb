module Spectrum
  module Config
    class MetadataComponent
      class << self
        def new(name, config)
          klass = get_type(config)
          return klass.new(name, config) if klass
          obj = allocate
          obj.send(:initialize, name, config)
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

      attr_accessor :name, :config

      def initialize(_, _)
      end

      def resolve(_)
        nil
      end

      def icons(_)
        nil
      end

    end
  end
end

