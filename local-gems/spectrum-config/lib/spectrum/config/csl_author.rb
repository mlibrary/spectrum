module Spectrum
  module Config
    class CSLAuthor < CSLBase
      def value(data)
        if data && data[:value]
          {id => [data[:value]].flatten.map {|name| {literal: name}}}
        else
          {}
        end
      end
    end
  end
end
