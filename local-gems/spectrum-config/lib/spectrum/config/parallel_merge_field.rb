# frozen_string_literal: true
module Spectrum
  module Config
    class ParallelMergeField < Field
      type 'parallel_merge'

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
        ret = []
        return ret if data.empty?
        flds = @fields.map do |field|
          [field['uid'], resolve_key(data, field['field'])]
        end.to_h
        0.upto(flds.values.first.length - 1) do |i|
          ret << @fields.map do |field|
            {
              'uid' => field['uid'],
              'name' => field['name'],
              'value' => flds[field['uid']][i],
              'value_has_html' => true
            }
          end
        end
        ret
      end
    end
  end
end
