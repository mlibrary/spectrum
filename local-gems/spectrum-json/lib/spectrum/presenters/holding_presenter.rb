module Spectrum::Presenters
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
  class AlmaHoldingPresenter < HoldingPresenter
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
