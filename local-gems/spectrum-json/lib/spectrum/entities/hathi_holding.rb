module Spectrum::Entities
  class HathiHolding
    def initialize(bib_record)
      @bib_record = bib_record
      @holding = bib_record.hathi_holding
    end
    def self.for(mms_id, url, 
                 bib_record=Spectrum::BibRecord.fetch(id: mms_id, url: url))
      HathiHolding.new(bib_record)
    end
    #
    # Things that respond with the empty string
    [:callnumber, :sub_library, :collection].each do |name|
      define_method(name) do
        ''
      end
    end
    def empty?
      @holding.nil?
    end
    def info_link
      nil
    end
    def library
      @holding&.library
    end
    def location
      @holding&.library
    end
    def mms_id
      @bib_record&.mms_id
    end
    def doc_id
      mms_id
    end
    def items 
      @holding&.items&.map{|x| Spectrum::Entities::HathiItem.new(self, x) } unless empty?
    end
    def id
      items&.first.id if items.count == 1
    end
    def status
      items&.first.status if items.count == 1
    end
    
  end
  class HathiItem
    extend Forwardable
    def_delegators :@holding, :mms_id, :doc_id, :callnumber, :sub_library, :collection, :holding_id, :location

    def initialize(holding, item)
      @holding = holding
      @item = item
    end
    
    [:description, :source, :rights, :id, :status].each do |name|
      define_method(name) do
        @item.public_send(name)
      end
    end

    def record
      @holding.mms_id
    end
    def url
      handle = "http://hdl.handle.net/2027/#{@item.id}"
      suffix = if status.include?('log in required')
        "?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth"
      else
        ''
      end
      "#{handle}#{suffix}"
    end
  end
end
