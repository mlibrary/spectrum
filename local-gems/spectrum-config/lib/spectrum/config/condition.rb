# frozen_string_literal: true
module Spectrum
  module Config
    class Condition
      def initialize(cond)
        @field = cond['field']
        @cmp   = cond['comparison'] || 'eq'
        @value = cond['value']
        @fields = cond['fields']
      end

      def value
        case @cmp
        when 'eq'
          val = yield(@field)
          val = val.first if Array === val
          if @value == val
            return @fields.map do |field_def|
              {
                'uid' =>  field_def['uid'],
                'name' => field_def['name'],
                'value' => (field_def['prepend'] || '') + yield(field_def['field']),
                'value_has_html' => true
              }
            end
          end
        end
        nil
      end
    end
  end
end
