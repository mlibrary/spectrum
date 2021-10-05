# frozen_string_literal: true
module Spectrum
  module Config
    class MoreInformationField < Field
      type 'more_information'

      def value(value, request)
        return nil unless (values = super(value, request))
        {
          term: name,
          description: values.map { |val| JSON.parse(val) }
        }
      end
    end
  end
end
