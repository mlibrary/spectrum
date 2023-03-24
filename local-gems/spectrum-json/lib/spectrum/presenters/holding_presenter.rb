module Spectrum
  module Presenters
    class HoldingPresenter
      def initialize(holding)
        @holding = holding
      end
      def self.for(holding)
        if holding.class.name.to_s.match(/Hathi/)
          HathiTrustHoldingPresenter.new(holding)
        #elsif holding.up_links || holding.down_links
          #LinkedHoldingPresenter.for(holding)
        elsif holding.library == 'ELEC'
          ElecHoldingPresenter.new(holding)
        elsif holding.library == 'EMPTY'
          EmptyHoldingPresenter.new(holding)
        else
          AlmaHoldingPresenter.new(holding)
        end
      end

      def to_h
        {
           caption: caption,
           captionLink: captionLink,
           name: name,
           notes: notes,
           headings: headings,
           rows: rows,
           type: type
        }.delete_if { |k,v| v.nil? || v.empty? }
      end

      private
      def caption
        @holding.display_name
      end
      def captionLink
        @holding.info_link ? {href: @holding.info_link, text: 'About location'} : nil
      end
      def name
        nil
      end
      def type
        'physical'
      end
      def headings
        []
      end
      def rows
        []
      end
      def notes
        nil
      end
    end

    #Will bring this back at some point, but right now it's not being used
    #class LinkedHoldingPresenter < HoldingPresenter
      #def self.for(input)
        #if input.holding.down_links
          #DownLinkedHolding.new(input)
        #else
          #UpLinkedHolding.new(input)
        #end
      #end

      #private
      #def headings
          #['Record link']
      #end
      #def name
        #nil
      #end

      #def process_link(link)
        #[
          #{
            #text: link['link_text'],
            #to: {
              #record: link['key'],
              #datastore: @holding.doc_id,
            #}
          #}
        #]
      #end
    #end
    #class DownLinkedHolding < LinkedHoldingPresenter
      #private
      #def caption
        #'Bound with'
      #end
      #def rows
        #@holding.down_links.map { |link| process_link(link) }
      #end
    #end
    #class UpLinkedHolding < LinkedHoldingPresenter
      #private
      #def caption
        #'Included in'
      #end
      #def rows
        #@holding.up_links.map { |link| process_link(link) }
      #end
    #end
  end
end
