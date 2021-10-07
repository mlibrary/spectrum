# frozen_string_literal: true
module Spectrum
  module Config
    class SummonYearField < Field
      type 'summon_year'

      def transform(value)
        return nil unless value
        value.year
      end
    end
  end
end
