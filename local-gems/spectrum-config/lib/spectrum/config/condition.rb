# frozen_string_literal: true

module Spectrum
  module Config
    class Condition
      def initialize(cond)
        @field = cond["field"]
        @comparison = cond["comparison"] || "eq"
        @value = cond["value"]
        @literal = cond["literal"]
      end

      def value
        case @comparison
        when "always"
          return yield(@field)
        when "include"
          val = yield(@field)
          return nil unless val
          if val.include?(@value)
            return @literal if @literal
          end
        end
        nil
      end
    end
  end
end
