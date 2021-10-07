# frozen_string_literal: true
module Spectrum
  module Config
    class SummonDateField < Field
      type 'summon_date'

      def transform(value)
        return nil unless value
        [value.day, value.month, value.year].compact.join('/')
      end
    end
  end
end
