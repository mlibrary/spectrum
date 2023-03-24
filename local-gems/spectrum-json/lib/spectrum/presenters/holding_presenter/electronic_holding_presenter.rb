module Spectrum
  module Presenters
    class ElecHoldingPresenter < HoldingPresenter
      def type
        "electronic"
      end
      def caption
        "Online Resources"
      end
      def headings 
        ['Link', 'Description', 'Source']
      end
      def rows
        @holding.items.map do |item|
          Spectrum::Presenters::ElectronicItem.for(item).to_a
        end
      end
    end
  end
end
