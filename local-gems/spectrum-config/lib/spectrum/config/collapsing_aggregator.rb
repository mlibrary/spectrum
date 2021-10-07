# frozen_string_literal: true
module Spectrum
  module Config
    class CollapsingAggregator < Aggregator
      type 'collapsing'

      def add(_metadata, field, subfield)
        @ret[field] ||= []
        @ret[field] << subfield.value
      end

      def to_value
        @ret.values.map { |value| value.join(' ') }
      end
    end
  end
end
