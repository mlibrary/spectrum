# frozen_string_literal: true
module Spectrum
  module Config
    class FieldFacet
      attr_reader :sorts, :ranges, :type, :expanded, :selected, :transform

      def initialize(data = {})
        data ||= {}
        @sorts = data['sorts']
        @ranges = data['ranges']
        @type   = data['type']
        @expanded = data['expanded']
        @selected = data['selected']
        @transform = data['transform']
      end
    end
  end
end
