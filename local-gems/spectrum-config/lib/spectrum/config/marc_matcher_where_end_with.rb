module Spectrum
  module Config
    class MarcMatcherWhereEndWith < MarcMatcherWhereClause
      attr_accessor :sub, :values
      type 'end_with'

      def initialize(cfg)
        cfg ||= {}
        self.sub = /#{cfg['sub']}/
        self.values = cfg['end_with']
      end

      def match?(field)
        return true unless sub && values
        find_all(field).any? { |subfield| values.any? { |val| subfield.value.end_with?(val) } }
      end
    end
  end
end
