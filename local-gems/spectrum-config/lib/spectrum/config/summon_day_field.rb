# frozen_string_literal: true
module Spectrum
  module Config
    class SummonDayField < Field
      type 'summon_day'

      def transform(value)
        return nil unless value
        value.day
      end
    end
  end
end
