require "alma_rest_client"
class Spectrum::Entities::AlmaHoldings
  attr_reader :holdings
  # A list of Alma holdings
  # @param alma [Hash] [Response from alma loans api check]
  # @param solr [Spectrum::BibRecord]
  def initialize(alma:, solr:)
    @alma = alma
    @solr = solr # Spectrum::BibRecord
    @holdings = load_holdings
  end

  def self.for(bib_record:, client: Spectrum::AlmaClient.client)
    if bib_record.physical_holdings?
      begin
        response = client.get_all(url: "/bibs/#{bib_record.mms_id}/loans", record_key: "item_loan")
        raise ::StandardError.new("problem with contacting alma") if response.status != 200
        Spectrum::Entities::AlmaHoldings.new(alma: response.body, solr: bib_record)
      rescue => e
        Logger.new($stdout).error "Cant'contact Alma: #{e}"
        Spectrum::Entities::AlmaHoldings.new(alma: {"item_loan" => []}, solr: bib_record)
      end
    else
      Spectrum::Entities::AlmaHoldings::Empty.new
    end
  end

  def find_item(barcode)
    @holdings.map { |h| h.items }
      .flatten
      .find { |i| i.barcode == barcode }
  end

  # Finds the element of the @holdings array. Treats an instance of Alma
  # Holdings as if it were an array.
  # @param index [[Integer]] [Array element index in @holdings instance variable]
  def [](index)
    @holdings[index]
  end

  def each(&block)
    @holdings.each(&block)
  end

  def empty?
    false
  end

  private

  def load_holdings
    @solr.alma_holdings.map do |solr_holding|
      alma_loans = @alma["item_loan"]&.select { |loan| loan["holding_id"] == solr_holding.holding_id }
      Spectrum::Entities::AlmaHolding.new(bib: @solr, alma_loans: alma_loans, solr_holding: solr_holding)
    end
  end
end

class Spectrum::Entities::AlmaHoldings::Empty
  def holdings
    []
  end

  def empty?
    true
  end
end

class Spectrum::Entities::AlmaHolding
  attr_reader :items, :bib_record, :solr_holding
  extend Forwardable
  def_delegators :@bib_record, :mms_id, :doc_id, :title, :author,
    :issn, :isbn, :pub_date
  def_delegators :@solr_holding, :holding_id, :floor_location,
    :callnumber, :library, :location,
    :summary_holdings, :display_name, :info_link, :can_reserve?

  # This may only need to be temporary.
  # The data structure in @solr_holding for public_note might be made multi-valued.
  # Then public_note could be delegated to @solr_holding again.
  def public_note
    @bib_record.fullrecord.find_all do |field|
      field.tag == "852" && field["b"] == library && field["c"] == location && field["8"] == holding_id
    end.map(&:subfields).flatten.select do |subfield|
      subfield.code == "z"
    end.map(&:value)
  end

  def initialize(bib:, alma_loans: [], solr_holding: nil)
    @bib_record = bib # now is solr BibRecord

    @solr_holding = solr_holding
    @items = solr_holding.items.map do |solr_item|
      alma_loan = alma_loans&.find { |loan| loan["item_id"] == solr_item.id }
      Spectrum::Entities::AlmaItem.new(holding: self, solr_item: solr_item, alma_loan: alma_loan,
        bib_record: @bib_record)
    end
  end
end
