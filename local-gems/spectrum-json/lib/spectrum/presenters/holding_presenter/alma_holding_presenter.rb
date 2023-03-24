module Spectrum
  module Presenters
    class AlmaHoldingPresenter < Spectrum::Presenters::HoldingPresenter
      private
      def headings
        ['Action', 'Description', 'Status', 'Call Number']
      end
      def name
        'holdings'
      end
      def notes
        [
          @holding.public_note,
          @holding.summary_holdings,
          @holding.floor_location
        ].compact.reject(&:empty?)
      end
      def rows
        @holding.items.map { |item| Spectrum::Presenters::PhysicalItem.new(item).to_a }
      end
    end
  end
end
