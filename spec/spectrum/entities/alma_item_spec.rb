require_relative '../../rails_helper'
describe Spectrum::Entities::AlmaItem do
  before(:each) do
    @solr_bib_alma = File.read('./spec/fixtures/solr_bib_alma.json')
    @alma_loan = JSON.parse(File.read('./spec/fixtures/alma_loans_one_holding.json'))["item_loan"][0]
  end
  subject do
    solr_bib_record = Spectrum::BibRecord.new(JSON.parse(@solr_bib_alma))
    solr_holding = solr_bib_record.alma_holding("2297537770006381")
    solr_item = solr_holding.items.first

    holding = instance_double(Spectrum::Entities::AlmaHolding, holding_id: "holding_id", bib_record: solr_bib_record, solr_holding: solr_holding, display_name: 'Hatcher Graduate Library')

    described_class.new(holding: holding,  alma_loan: @alma_loan, solr_item: solr_item, bib_record: solr_bib_record)
  end
  it "has a bib title" do
    expect(subject.title).to eq("Enhancing faculty careers : strategies for development and renewal /")
  end
  
  it "has a callnumber" do
    expect(subject.callnumber).to eq('LB 2331.72 .S371 1990')
  end
  it "has a pid" do
    expect(subject.pid).to eq("2397537760006381")
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
    expect(subject.process_type).to eq('LOAN')
  end
  it "calculates etas" do
    expect(subject.etas?).to eq(true)
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

  it "has #record_has_finding_aid" do
    expect(subject.record_has_finding_aid).to eq(false)
  end
  context "#in_reserves?" do
    it "is false for an item not in a reserve location" do
      expect(subject.in_reserves?).to eq(false)
    end
    it "is true for an item in a reserve location" do
      @solr_bib_alma.gsub!('\"permanent_location\":\"GRAD\"','\"location\":\"RESC\"')
      expect(subject.in_reserves?).to eq(true)
    end
  end

  context "#in_unavailable_temporary_location?" do
    it "is true for item in 'FVL LRC'" do
      @solr_bib_alma.gsub!('\"temp_location\":false','\"temp_location\":true')
      @solr_bib_alma.gsub!('\"location\":\"GRAD\"','\"location\":\"LRC\"')
      @solr_bib_alma.gsub!('\"library\":\"HATCH\"','\"library\":\"FVL\"')
      expect(subject.in_unavailable_temporary_location?).to eq(true)
    end
    it "is not true for item not in a temporary location" do
      expect(subject.in_unavailable_temporary_location?).to eq(false)
    end
  end

  context "item checked back in today" do
    before(:each) do
      @solr_bib_alma.gsub!('\"process_type\":null','\"process_type\":\"LOAN\"')
      @alma_loan = nil
    end
    it "does not have a due date" do
      expect(subject.due_date).to eq(nil)
    end
    it "does not have a process type" do
      expect(subject.process_type).to eq(nil)
    end
  end
  context "item is lost" do
    it "returns lost process type if item is lost" do
      @alma_loan["process_status"] = "LOST"
      @solr_bib_alma.gsub!('\"process_type\":null','\"process_type\":\"LOST_LOAN\"')
      expect(subject.process_type).to eq("LOST_LOAN")
    end
  end
  
end
