# frozen_string_literal: true

module Spectrum
  module FieldTree
    class Literal < ChildFreeBase
      def query(_field_map = {})
        # RSolr.solr_escape(@value.to_s)
        @value.to_s
      end
    end
  end
end
