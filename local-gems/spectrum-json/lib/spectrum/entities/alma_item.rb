# TBD #status, #temp_location?
class Spectrum::Entities::AlmaItem
  extend Forwardable
  def_delegators :@holding, :holding_id, :public_note

  def_delegators :@bib_record, :mms_id, :doc_id, :etas?, :title, :author,
    :restriction, :edition, :physical_description, :date, :pub, :place,
    :publisher, :pub_date, :issn, :isbn, :genre, :sgenre, :accession_number,
    :finding_aid, :fullrecord, :oclc

  def_delegators :@solr_item, :callnumber, :temp_location?, :barcode, :library,
    :location, :permanent_library, :permanent_location, :description, :item_policy,
    :process_type, :inventory_number, :can_reserve?, :item_id, :record_has_finding_aid,
    :item_location_text, :item_location_link, :fulfillment_unit, :location_type, :material_type

  def initialize(holding:, solr_item:, bib_record:, alma_loan: nil)
    @holding = holding # AlmaHolding
    @alma_loan = alma_loan # parsed_response
    @solr_item = solr_item # BibRecord::AlmaHolding::Item
    @bib_record = bib_record # BibRecord
  end

  def pid
    @solr_item.id
  end

  # List of loan process statuses that imply that the item is on loan. The
  # commented out statuses we handle in different ways. Documention:
  # https://developers.exlibrisgroup.com/alma/apis/docs/xsd/rest_item_loan.xsd/?tags=GET
  def alma_says_on_loan?
    [
      "AT_SHELF",
      "AT_USER",
      "AUTO_RENEW",
      "BULK_CHANGE_BACKWARD",
      "BULK_CHANGE_FORWARD",
      # "CLAIMED_RETURN",
      "FOUND_ITEM",
      "LOAN",
      # "LOST",
      # "LOST_AND_PAID",
      # "LOST_NO_FEE",
      "MEDIATED_RENEWAL",
      "NORMAL",
      # "OVERDUE_CLAIMED_RETURN",
      # "OVERDUE_LOST",
      "OVERDUE_NOTIFICATION",
      "READING_ROOM_AT_SHELF",
      "READING_ROOM_AT_USER",
      "RECALL",
      "RENEW",
      "RENEW_REJECTED",
      "RENEW_REQUESTED",
      # "RETURN",
      "UNDO_RENEW",
      "UNDO_RETURN",
      "WB_CHANGE_BACKWARD",
      "WB_CHANGE_FORWARD"
    ].include?(@alma_loan&.dig("process_status"))
  end

  def process_type
    if alma_says_on_loan?
      "LOAN"
    elsif @solr_item.process_type == "LOAN"
      # if Solr still says there's a loan, but alma doesn't have a loan for the item
      nil
    else
      @solr_item.process_type
    end
  end

  def due_date
    @alma_loan&.dig("due_date")
  end

  # Library and Location name
  def library_display_name
    @holding.display_name
  end

  def in_reserves?
    ["CAR", "OPEN", "RESI", "RESP", "RESC", "ERES"].include?(@solr_item.location)
  end

  def not_in_reserves?
    !in_reserves?
  end

  def in_game?
    @solr_item.library == "SHAP" && @solr_item.location == "GAME"
  end

  def in_unavailable_temporary_location?
    @solr_item.temp_location? && ["FVL LRC"].include?("#{@solr_item.library} #{@solr_item.location}")
  end

  def reservable_library?
    ["FVL"].include?(@solr_item.library)
  end

  def not_reservable_library?
    !reservable_library?
  end
end
