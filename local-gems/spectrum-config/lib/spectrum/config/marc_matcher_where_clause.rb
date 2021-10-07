module Spectrum
  module Config
    class MarcMatcherWhereClause
      class << self
        def new(config)
          klass = get_type(config)
          return klass.new(config) if klass
          obj = allocate
          obj.send(:initialize, config)
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
          registry.find {|item| config[item.type] }
        end

        def registry
          @registry ||= []
        end
      end

      attr_accessor :sub, :values
      
      def initialize(cfg)
        self.sub = //
        self.values = []
      end

      def find_all(field)
        return [] unless field.respond_to?(:find_all)
        field.find_all do |subfield|
          sub.match(subfield.code) && values.include?(subfield.value)
        end
      end

      def match?(field)
        true
      end
    end
  end
end
