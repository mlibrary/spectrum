# frozen_string_literal: true

module Spectrum
  module FieldTree
    class Raw < ChildFreeBase
      def query(_field_map = {})
        @value.to_s.gsub(/all_?fields:/, '')
      end
    end
  end
end
