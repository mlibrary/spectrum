module Spectrum
  module Config
    class CSLBase
      attr_accessor :id
      def initialize(id)
        self.id = id
      end
    end
  end
end
