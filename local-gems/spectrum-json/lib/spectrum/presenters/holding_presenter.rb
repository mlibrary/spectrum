module Spectrum
  module Presenters
    module HoldingPresenter
      def self.for(holding)
        if /Hathi/.match?(holding.class.name.to_s)
          HathiHoldingPresenter.new(holding)
          # elsif holding.up_links || holding.down_links
          # LinkedHoldingPresenter.for(holding)
        elsif holding.library == "EMPTY"
          EmptyHoldingPresenter.new(holding)
        elsif holding.library == "ELEC"
          ElectronicHoldingPresenter.new(holding)
        else
          AlmaHoldingPresenter.new(holding)
        end
      end

      # Will bring this back at some point, but right now it's not being used
      # class LinkedHoldingPresenter < HoldingPresenter
      # def self.for(input)
      # if input.holding.down_links
      # DownLinkedHolding.new(input)
      # else
      # UpLinkedHolding.new(input)
      # end
      # end

      # private
      # def headings
      # ['Record link']
      # end
      # def name
      # nil
      # end

      # def process_link(link)
      # [
      # {
      # text: link['link_text'],
      # to: {
      # record: link['key'],
      # datastore: @holding.doc_id,
      # }
      # }
      # ]
      # end
      # end
      # class DownLinkedHolding < LinkedHoldingPresenter
      # private
      # def caption
      # 'Bound with'
      # end
      # def rows
      # @holding.down_links.map { |link| process_link(link) }
      # end
      # end
      # class UpLinkedHolding < LinkedHoldingPresenter
      # private
      # def caption
      # 'Included in'
      # end
      # def rows
      # @holding.up_links.map { |link| process_link(link) }
      # end
      # end
    end
  end
end
