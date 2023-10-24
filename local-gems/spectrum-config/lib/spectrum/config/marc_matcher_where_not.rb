module Spectrum
  module Config
    class MarcMatcherWhereNot < MarcMatcherWhereClause
      attr_accessor :sub, :values
      type 'not'

      def initialize(cfg)
        cfg ||= {}
        self.sub = cfg['sub']
        self.values = cfg['not']
      end

      def match?(field)
        return true unless sub && values
        find_all(field).all? { |subfield| !values.include?(subfield.value) }
      end

    end
  end
end
