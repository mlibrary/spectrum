module Spectrum
  module Config
    class CSLAuthor < CSLBase
      def value(data)
        if data && data[:value]
          {id => [data[:value]].flatten.map {|name| objectify_name(name)}}
        else
          {}
        end
      end

      def objectify_name(name)
        if name.include?(", ")
          family, given = name.split(", ")
          { family: family, given: given }
        else
          { literal: name }
        end
      end
    end
  end
end
