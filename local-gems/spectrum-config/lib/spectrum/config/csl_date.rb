module Spectrum
  module Config
    class CSLDate < CSLBase
      def value(data)
        if data && data[:value]
          {id => {literal: [data[:value]].flatten.first}}
        else
          {}
        end
      end
    end
  end
end
