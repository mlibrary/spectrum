# frozen_string_literal: true
module Spectrum
  module Config
    class MarcJSONField < Field
      type 'marcjson'

      def value(data, request = nil)
        MARC::XMLReader.new(StringIO.new(super)).first.to_hash
      end
    end
  end
end
