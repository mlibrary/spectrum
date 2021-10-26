module Spectrum
  class Presenters::ElectronicItem
    def initialize(item)
      @item = item
    end
    def self.for(item)
      if item.status == 'Not Available'
        UnavailableElectronicItem.new(item)
      else
        self.new(item)
      end
    end
    def to_a
      [
        link,
        {text: description},
        {text: note}
      ]
    end
    def description
      @item.description || ''
    end
    def note
      @item.note || 'N/A'
    end
    def link_text
      @item.link_text || 'Available online'
    end
    def link
      { text: link_text, href: @item.link}
    end
    class UnavailableElectronicItem < self
      def link
        { text: 'Coming soon.' }
      end
      def description
        [ 'Link will update when access is available.', @item.description || ''].join(' ').strip 
      end
    end
  end
end