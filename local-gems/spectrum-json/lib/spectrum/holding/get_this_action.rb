module Spectrum
  class Holding
    class GetThisAction < Action
      def self.label
        'Get This'
      end

      def finalize
        super.merge(
          to: {
            barcode: @item.barcode,
            action: 'get-this',
            record: @item.doc_id,
            datastore: @item.doc_id,
          }
        )
      end
    end
  end
end
