module Spectrum
  class Holding
    class RequestThisAction < Action
      def self.label
        'Request This' 
      end
      def self.for(item)
        case item.library
        when 'CLEM'
          ClementsRequestThisAction.new(item, Spectrum::ClementsBibRecord.new(item.fullrecord)) 
        when 'BENT'
          BentleyRequestThisAction.new(item, Spectrum::SpecialCollectionsBibRecord.new(item.fullrecord))
        else
          RequestThisAction.new(item, Spectrum::SpecialCollectionsBibRecord.new(item.fullrecord))
        end
      end

      def self.match?(item)
        item.can_reserve?
      end

      def initialize(item, bib)
        @bib = bib 
        @item = item
      end

      def finalize
        super.merge(href: href)
      end

      private
      
    [
      :title,
      :author, 
      :genre,
      :sgenre,
      :date,
      :edition,
      :publisher,
      :place,
      :extent,
      :sysnum,
    ].each do |name|
      define_method(name) do
        (@bib.public_send(name) || '').slice(0, 250)
      end
    end
      def callnumber
        @item.callnumber
      end

      def barcode
        @item.barcode
      end
      def description
        (@item.description || '').slice(0, 250)
      end

      def location
        @item.library
      end
      def sublocation
        @item.location
      end
      def fixedshelf
        @item.inventory_number
      end

      def isbn
        @item.isbn
      end
      def issn
        @item.issn
      end

      def sysnum
        @item.mms_id
      end

      def base_url
        'https://aeon.lib.umich.edu/logon?'
      end

      def query
        {
          Action: '10',
          Form: '30',
          callnumber: callnumber,
          genre: genre,
          sgenre: sgenre,
          title: title,
          author: author,
          date: date,
          edition: edition,
          publisher: publisher,
          place: place,
          extent: extent,
          barcode: barcode,
          description: description,
          sysnum: sysnum,
          location: location,
          sublocation: sublocation,
          fixedshelf: fixedshelf,
          issn: issn,
          isbn: isbn,
        }.to_query
      end

      def href
        base_url + query
      end

    end
    class ClementsRequestThisAction < RequestThisAction 
      def base_url 
        'https://aeon.clements.umich.edu/logon?'
      end
      def location
        ''
      end
      def sublocation
        @item.location
      end
    end
    class BentleyRequestThisAction < RequestThisAction 
      def base_url 
        'https://aeon.bentley.umich.edu/login?'
      end
      def location
        ''
      end
    end
  end
end
