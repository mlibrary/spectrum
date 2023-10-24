module Spectrum
  module Config
    class MarcMatcherWhereNotEndWith < MarcMatcherWhereClause
      attr_accessor :sub, :values
      type 'not_end_with'

      def initialize(cfg)
        cfg ||= {}
        self.sub = /#{cfg['sub']}/
        self.values = cfg['not_end_with']
      end

      def match?(field)
        return true unless sub && values
        find_all(field).all? { |subfield| !values.any? { |val| subfield.value.end_with?(val) } }
      end
    end
  end
end
