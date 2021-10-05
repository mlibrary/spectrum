# frozen_string_literal: true
module Spectrum
  module Config
    class MarcMatcher
      attr_reader :label, :join, :filters, :default

      def metadata
        {
          label: label,
          join: join,
          filters: filters,
        }
      end

      def initialize(arg)
        @label = arg['label'] || "#{arg['tag']} #{arg['ind1']}#{arg['ind2']} #{arg['sub']}"
        @join  = arg['join']
        @filters = (arg['filters'] || []).map(&:symbolize_keys)
        @tag   = /#{arg['tag'] || '.'}/
        @sub   = /#{arg['sub'] || '.'}/
        @ind1  = /#{arg['ind1'] || '.'}/
        @ind2  = /#{arg['ind2'] || '.'}/
        @where = MarcMatcherWhere.new(arg['where'])
        @default = arg['default']
      end

      def match_field(field)
        if @tag.match(field.tag)
          match_indicators(field) && @where.match?(field)
        else
          false
        end
      end

      def match_subfield(subfield)
        @sub.match(subfield.code)
      end

      def match_indicators(field)
        return true unless field.respond_to?(:indicator1) && field.respond_to?(:indicator2)
        @ind1.match(field.indicator1) && @ind2.match(field.indicator2)
      end

    end
  end
end
