module Spectrum
  module Config
    class CSLLiteral < CSLBase
      def value(data)
        if data && data[:value]
          { id => [data[:value]].flatten.first }
        else
          {}
        end
      end
    end
  end
end
