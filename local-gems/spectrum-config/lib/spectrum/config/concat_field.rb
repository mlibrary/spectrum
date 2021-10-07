# frozen_string_literal: true
module Spectrum
  module Config
    class ConcatField < Field
      type 'concat'

      attr_reader :join

      def initialize_from_instance(i)
        super
        @join = i.join
      end

      def initialize_from_hash(args, config = {})
        super
        @join = args['join'] || ''
      end

      def value(data, request = nil)
        val = @field.map { |name| resolve_key(data, name) }.flatten.compact.join(@join)
        return nil if val.nil? || val.empty?
        val
      end
    end
  end
end
