# frozen_string_literal: true
module Spectrum
  module Config
    class SolrYearField < Field
      type 'solr_year'

      def transform(value)
        return nil unless value
        value&.slice(0, 4)
      end
    end
  end
end
