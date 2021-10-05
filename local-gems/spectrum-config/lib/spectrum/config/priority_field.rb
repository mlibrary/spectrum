# frozen_string_literal: true
module Spectrum
  module Config
    class PriorityField < Field
      type 'priority'

      def value(data, request = nil)
        val = @field.map { |name| resolve_key(data, name) }.flatten.compact.first
        return nil if val.nil? || val.empty?
        val
      end
    end
  end
end
