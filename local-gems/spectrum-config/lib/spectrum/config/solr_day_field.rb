# frozen_string_literal: true
module Spectrum
  module Config
    class SolrDayField < Field
      type 'solr_day'

      def transform(value)
        return nil unless value
        value.slice(8, 2).sub(/^0*/, '') if value
      end
    end
  end
end
