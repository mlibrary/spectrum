# frozen_string_literal: true
module Spectrum
  module Config
    class SummonMonthField < Field
      type 'summon_month'

      def transform(value)
        return nil unless value
        value.month
      end
    end
  end
end
