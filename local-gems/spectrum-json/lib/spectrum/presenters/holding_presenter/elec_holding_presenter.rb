module Spectrum
  module Presenters
    class ElecHoldingPresenter < HoldingPresenter
      def headings 
        ['Link', 'Description', 'Source']
      end
      def caption
        "Online Resources"
      end
      def type
        "electronic"
      end
      def rows
        @holding.items.map do |item|
          Spectrum::Presenters::ElectronicItem.for(item).to_a
          #[ 
            #{text: item.link_text, href: item.link},
            #{text: item.description || ''},
            #{text: item.note || 'N/A'}
          #]
        end
      end
    end
  end
end
