require_relative "../../spec_helper"
describe Spectrum::Entities::AlmaItem do
  before(:each) do
    @solr_bib_alma = File.read("./spec/fixtures/solr_bib_alma.json")
    @alma_loan = JSON.parse(File.read("./spec/fixtures/alma_loans_one_holding.json"))["item_loan"][0]
  end
  subject do
    solr_bib_record = Spectrum::BibRecord.new(JSON.parse(@solr_bib_alma))
    solr_holding = solr_bib_record.alma_holding("22957681780006381")
    solr_item = solr_holding.items.first

    holding = instance_double(Spectrum::Entities::AlmaHolding, holding_id: "holding_id", bib_record: solr_bib_record, solr_holding: solr_holding, display_name: "Hatcher Graduate Library")

    described_class.new(holding: holding, alma_loan: @alma_loan, solr_item: solr_item, bib_record: solr_bib_record)
  end
  it "has a bib title" do
    expect(subject.title).to eq("Enhancing faculty careers : strategies for development and renewal /")
  end

  it "has a callnumber" do
    expect(subject.callnumber).to eq("LB 2331.72 .S371 1990")
  end
  it "has a pid" do
    expect(subject.pid).to eq("23957681750006381")
  end
  it "has a barcode" do
    expect(subject.barcode).to eq("39015017893416")
  end
  it "has a library" do
    expect(subject.library).to eq("HATCH")
  end

  it "has a location" do
    expect(subject.location).to eq("GRAD")
  end
  it "has an inventory_number" do
    expect(subject.inventory_number).to eq(nil)
  end
  it "returns temp_location status" do
    expect(subject.temp_location?).to eq(false)
  end
  it "returns a description" do
    expect(subject.description).to eq(nil)
  end
  it "returns a process type" do
    @solr_bib_alma.gsub!('\"process_type\":null', '\"process_type\":\"LOAN\"')
    expect(subject.process_type).to eq("LOAN")
  end
  it "calculates etas" do
    expect(subject.etas?).to eq(false)
  end
  it "has fulfillment_unit" do
    expect(subject.fulfillment_unit).to eq("General")
  end
  it "has a location_type" do
    expect(subject.location_type).to eq(nil)
  end
  it "has a due_date" do
    expect(subject.due_date).to eq("2021-10-01T03:59:00Z")
  end
  it "has a library_display_name" do
    expect(subject.library_display_name).to eq("Hatcher Graduate Library")
  end
  it "has can_reserve? flag" do
    expect(subject.can_reserve?).to eq(false)
  end

  # mrio: 2022-09 per request from Dave in CVGA that items in SHAP Game
  #      are only "Find it in the Library"; Media Fullfillment Unit is
  #      pretty inconsistent so we can't use that
  context "#in_game?" do
    it "is true when in SHAP GAME" do
      @solr_bib_alma.gsub!('\"library\":\"HATCH\"', '\"library\":\"SHAP\"')
      @solr_bib_alma.gsub!('\"permanent_location\":\"GRAD\"', '\"location\":\"GAME\"')
      expect(subject.in_game?).to eq(true)
    end
    it "is not true when not in SHAP GAME" do
      expect(subject.in_game?).to eq(false)
    end
  end

  it "has #record_has_finding_aid" do
    expect(subject.record_has_finding_aid).to eq(false)
  end
  context "#in_reserves?" do
    it "is false for an item not in a reserve location" do
      expect(subject.in_reserves?).to eq(false)
    end
    it "is true for an item in a reserve location" do
      @solr_bib_alma.gsub!('\"permanent_location\":\"GRAD\"', '\"location\":\"RESC\"')
      expect(subject.in_reserves?).to eq(true)
    end
  end
  context "#in_deep_storage?" do
    it "is false for an item not in deep storage" do
      expect(subject.in_deep_storage?).to eq(false)
    end
    it "is true for an item in a reserve location (temporary or permanent)" do
      @solr_bib_alma.gsub!('\"library\":\"HATCH\"', '\"library\":\"OFFS\"')
      @solr_bib_alma.gsub!('\"location\":\"GRAD\"', '\"location\":\"DEEP\"')
      expect(subject.in_deep_storage?).to eq(true)
    end
  end
  context "reservable_library?" do
    it "is true if the library is \"FVL\"" do
      @solr_bib_alma.gsub!('\"library\":\"HATCH\"', '\"library\":\"FVL\"')
      expect(subject.reservable_library?).to eq(true)
    end
    it "is false if the library is anything other than \"FVL\"" do
      expect(subject.reservable_library?).to eq(false)
    end
  end
  context "not_reservable_library?" do
    it "is true if the library is anything other than \"FVL\"" do
      expect(subject.not_reservable_library?).to eq(true)
    end
    it "is false if the library is  \"FVL\"" do
      @solr_bib_alma.gsub!('\"library\":\"HATCH\"', '\"library\":\"FVL\"')
      expect(subject.not_reservable_library?).to eq(false)
    end
  end

  context "#in_unavailable_temporary_location?" do
    it "is true for item in 'FVL LRC'" do
      @solr_bib_alma.gsub!('\"temp_location\":false', '\"temp_location\":true')
      @solr_bib_alma.gsub!('\"location\":\"GRAD\"', '\"location\":\"LRC\"')
      @solr_bib_alma.gsub!('\"library\":\"HATCH\"', '\"library\":\"FVL\"')
      expect(subject.in_unavailable_temporary_location?).to eq(true)
    end
    it "is not true for item not in a temporary location" do
      expect(subject.in_unavailable_temporary_location?).to eq(false)
    end
  end

  context "item checked back in today" do
    before(:each) do
      @solr_bib_alma.gsub!('\"process_type\":null', '\"process_type\":\"LOAN\"')
      @alma_loan = nil
    end
    it "does not have a due date" do
      expect(subject.due_date).to eq(nil)
    end
    it "does not have a process type" do
      expect(subject.process_type).to eq(nil)
    end
  end
  context "item is checked out today" do
    it "returns the due date" do
      @alma_loan["process_status"] = "LOAN"
      expect(subject.process_type).to eq("LOAN")
    end
  end
  context "item is lost" do
    it "returns lost process type if item is lost" do
      @alma_loan["process_status"] = "LOST"
      @solr_bib_alma.gsub!('\"process_type\":null', '\"process_type\":\"LOST\"')
      expect(subject.process_type).to eq("LOST")
    end
  end
  context "item is claimed returned" do
    it "returns lost process type if item is lost" do
      @alma_loan["process_status"] = "CLAIMED_RETURN"
      @solr_bib_alma.gsub!('\"process_type\":null', '\"process_type\":\"CLAIM_RETURNED_LOAN\"')
      expect(subject.process_type).to eq("CLAIM_RETURNED_LOAN")
    end
  end
end
