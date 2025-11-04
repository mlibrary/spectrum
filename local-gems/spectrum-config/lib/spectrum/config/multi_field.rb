# frozen_string_literal: true
module Spectrum
  module Config
    class MultiField < Field
      type 'multi'

      attr_reader :fields

      def initialize_from_instance(i)
        super
        @fields = i.fields
      end

      def initialize_from_hash(args, config = {})
        super
        @fields = args['fields']
      end

      def value(data, request = nil)
        fields.map do |fld|
          resolve_key(data, fld)
        end.flatten.compact.map do |val|
          mapping.fetch(val, val)
        end
      end
    end
  end
end
