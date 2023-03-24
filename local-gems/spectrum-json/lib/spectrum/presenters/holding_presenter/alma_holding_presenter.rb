module Spectrum
  module Presenters
    class AlmaHoldingPresenter < Spectrum::Presenters::HoldingPresenter
      private

      def caption
        @holding.display_name
      end

      def captionLink
        @holding.info_link ? {href: @holding.info_link, text: "About location"} : nil
      end

      def headings
        ["Action", "Description", "Status", "Call Number"]
      end

      def name
        "holdings"
      end

      def type
        "physical"
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
