# frozen_string_literal: true
module Spectrum
  module Config
    class ConcatenateMergeField < Field
      type 'concatenate_merge'

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
        # Wrap the result in an array for parity with ParallelMergeField.
        [
          @fields.map do |field|
            if field['preferred']
              val = field['preferred'].map { |fld| resolve_key(data, fld) }.join('')
            else
              val = nil
            end

            if val.nil? || val.empty?
              val = field['fields'].map { |fld| resolve_key(data, fld) }.join('')
            end

            {
              'uid' =>  field['uid'],
              'name' => field['name'],
              'value' => val,
              'value_has_html' => true
            }
          end
        ]
      end
    end
  end
end
