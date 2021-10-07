module Spectrum
  module Config
    class MarcMatcherWhereExists < MarcMatcherWhereClause
      attr_accessor :sub, :values
      type 'exists'

      def initialize(cfg)
        cfg ||= {}
        self.sub = cfg['sub']
        self.values = Struct.new(:ret) { def include?(val) ret end }.new(true)
      end

      def match?(field)
        return true unless sub
        !find_all(field).empty?
      end
    end
  end
end
