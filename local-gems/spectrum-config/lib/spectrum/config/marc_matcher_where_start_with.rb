module Spectrum
  module Config
    class MarcMatcherWhereStartWith < MarcMatcherWhereClause
      attr_accessor :sub, :values
      type 'start_with'

      def initialize(cfg)
        cfg ||= {}
        self.sub = /#{cfg['sub']}/
        self.values = cfg['start_with']
      end

      def match?(field)
        return true unless sub && values
        !find_all(field).reject { |subfield| !values.any? { |val| subfield.value.start_with?(val) } }.empty?
      end
    end
  end
end
