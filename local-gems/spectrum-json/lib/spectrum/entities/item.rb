module Spectrum::Entities
  class GetHoldingsItem
    extend Forwardable
    def_delegators :@holding, :doc_id, :callnumber, :sub_library, :collection, :holding_id, :location
    def initialize(holding, item)
      @holding = holding
      @item = item
    end
    def record
      doc_id
    end
    def self.for(holding, item)
      if holding.class.name.to_s =~ /Hathi/
        HathiItem.new(holding, item)
      else
        MirlynItem.new(holding, item)
      end
    end
    def raw
      @item
    end
    def description
      @item['description'] || ''
    end
    def status
      @item["status"]
    end
  end
  class MirlynItem < GetHoldingsItem
    def barcode
      @item["barcode"]
    end
    def can_book?
      @item["can_book"]
    end
    def can_request?
      @item['can_request'] ||
        ['HSRS', 'HERB', 'MUSM'].include?(sub_library)
    end
    def can_reserve?
      @item["can_reserve"]
    end
    def full_item_key
      @item["full_item_key"]
    end

    def inventory_number
      @item['inventory_number']
    end
    def item_process_status
      @item['item_process_status']
    end
    def item_expected_arrival_date
      @item['item_expected_arrival_date']
    end
    def item_status
      @item['item_status']
    end
    def issue
      @item['description'] || ''
    end
    def notes
      @item['description'] || ''
    end
    def temp_location?
      @item['temp_location'] 
    end

  end
  class HathiItem < GetHoldingsItem
    def id
      @item["id"]
    end
    def source
      @item["source"]
    end
    def rights
      @item["rights"]
    end
  end
  class EmptyItem
    def can_book?; false end
    def can_reserve?; false end
    def can_request?; false end
    def status; '' end
    def location; '' end
  end
end
