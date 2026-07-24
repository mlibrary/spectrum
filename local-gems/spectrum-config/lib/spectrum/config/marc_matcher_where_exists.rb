module Spectrum
  module Config
    class MarcMatcherWhereExists < MarcMatcherWhereClause
      attr_accessor :sub, :values
      type 'exists'

      def initialize(cfg)
        cfg ||= {}
        self.sub = cfg['sub']
        self.values = cfg['exists']
      end

      def match?(field)
        return true unless sub
        if find_all(field).empty?
          return !values
        else
          return values
        end
      end
    end
  end
end
