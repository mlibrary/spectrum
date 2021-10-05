# frozen_string_literal: true
module Spectrum
  module Config
    class Aggregator
      class << self
        def new(type)
          klass = get_class(type)
          return klass.new(type) if klass
          obj = allocate
          obj.send(:initialize)
          obj
        end

        def inherited(base)
          registry << base
        end

        def type(t = nil)
          @type = t if t
          @type
        end

        private

        def get_class(type)
          reindex!
          return index[type] if index[type]
          return registry.first unless registry.empty?
          nil
        end

        def reindex!
          return unless dirty?
          registry.each do |item|
            index[item.type] = item
          end
        end

        def registry
          @registry ||= []
        end

        def dirty?
          registry.length > index.length
        end

        def index
          @index ||= {}
        end
      end

      def initialize
        @ret = {}
      end
    end
  end
end
