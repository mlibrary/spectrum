# frozen_string_literal: true
module Spectrum
  module Config
    class ListAggregator < Aggregator
      type 'list'

      def add(_metadata, field, subfield)
        @ret[field] ||= []
        @ret[field] << subfield.value
      end

      def to_value
        @ret.values.flatten
      end
    end
  end
end
