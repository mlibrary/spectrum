# frozen_string_literal: true

module Spectrum
  module Config
    class ConditionalMergeField < Field
      type "conditional_merge"

      attr_reader :conditions

      def initialize_from_instance(i)
        super
        @conditions = i.conditions
      end

      def initialize_from_hash(args, config = {})
        super
        @conditions = (args["conditions"] || []).map do |condition|
          Condition.new(condition)
        end
      end

      def value(data, request = nil)
        @conditions.map do |condition|
          condition.value do |key|
            resolve_key(data, key)
          end
        end.compact.flatten
      end
    end
  end
end
