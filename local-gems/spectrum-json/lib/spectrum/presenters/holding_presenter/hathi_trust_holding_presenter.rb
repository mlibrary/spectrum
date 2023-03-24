module Spectrum
  module Presenters
    class HathiTrustHoldingPresenter < HoldingPresenter
      private
      def caption
        @holding.library
      end
      def captionLink
        @holding.info_link
      end
      def headings
        ['Link', 'Description', 'Source']
      end
      def type
        'electronic'
      end
      def name
        'HathiTrust Sources'
      end
      def rows
        @holding.items.map do |item| 
          [
            {text: item.status, href: item.url},
            {text: item.description || ''},
            {text: item.source || 'N/A'}
          ]
        end
      end
    end
  end
end
