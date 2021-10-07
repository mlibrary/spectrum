module Spectrum
  module Config
    class CSLArray < CSLBase
      def value(data)
        if data && data[:value]
          {id => [data[:value]].flatten}
        else
          {}
        end
      end
    end
  end
end
