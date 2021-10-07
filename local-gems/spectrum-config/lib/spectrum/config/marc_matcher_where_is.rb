module Spectrum
  module Config
    class MarcMatcherWhereIs < MarcMatcherWhereClause
      attr_accessor :sub, :values
      type 'is'

      def initialize(cfg)
        cfg ||= {}
        self.sub = /#{cfg['sub']}/
        self.values = cfg['is']
      end

      def match?(field)
        return true unless sub && values
        !find_all(field).empty?
      end
    end
  end
end
