module Spectrum::Entities
  class Holdings
    attr_reader :holdings, :doc_id
    def initialize(data)
      @doc_id = data.keys.first
      @holdings = (data[@doc_id] || []).map { |h| Holding.for(@doc_id, h) } 
    end
    def self.for(source, request)
      response = HTTParty.get("#{source.holdings}#{request.id}")
      if response.code == 200
        Holdings.new(response.parsed_response)
      else
        Holdings.new({request.id => []})
      end
    end
    def hathi_holdings
      @holdings.find_all{|x| x.class.name.to_s.match(/HathiHolding/) }
    end
    def [](index)
      @holdings[index]
    end
    def each(&block)
      @holdings.each(&block)
    end
    def find_item(barcode)
      items = mirlyn_holdings.map{|x| x.items }.flatten
      item = items.find {|x| x.barcode == barcode }
      item ? item : EmptyItem.new
    end

    def find_item_by_item_key(item_key)
      items = mirlyn_holdings.map{|x| x.items }.flatten
      item = items.find {|x| x.full_item_key == item_key }
      item ? item : EmptyItem.new
    end

    def empty?
      @holdings.empty?
    end
    private
    def mirlyn_holdings
      @holdings.filter{|x| x.class.name.to_s.match(/MirlynHolding/) }
    end
  end

  class Holding
    attr_reader :doc_id
    def initialize(doc_id, data)
      @doc_id = doc_id
      @data = data
    end
    def self.for(doc_id, data)
      if data['location'] == 'HathiTrust Digital Library'
        HathiHolding.new(doc_id, data)
      else
        MirlynHolding.new(doc_id, data)
      end
    end
    def items
      @data["item_info"].map{|x| GetHoldingsItem.for(self, x) }
    end

    def callnumber
      @data["callnumber"]
    end
    def library
      @data["sub_library"]
    end
    def sub_library
      @data["sub_library"]
    end
    def collection
      @data["collection"]
    end
    def info_link
      @data["info_link"]
    end
    def location
      @data["collection"]
    end
    def status
      @data["status"]
    end

    def empty?
      @data.empty?
    end
  end
  class MirlynHolding < Holding
    def holding_id
      @data["hol_doc_number"]
    end
    def up_links
      @data["up_links"]
    end
    def down_links
      @data["down_links"]
    end
    def public_note
      @data["public_note"]
    end
    def summary_holdings
      @data["summary_holdings"]
    end
  end
  class HathiHolding < Holding
    def id
      @data["id"]
    end
  end
end
