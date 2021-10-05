module Spectrum
  module Config
    module Z3988
      def self.new(hsh)
        return Z3988Null unless hsh
        case hsh['type']
        when 'constant'
          Z3988Constant
        when 'rft_genre'
          Z3988RftGenre
        when 'rft_val_fmt'
          Z3988RftValFmt
        else
          Z3988Literal
        end.new(hsh)
      end
    end
  end
end
