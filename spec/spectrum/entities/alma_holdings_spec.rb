require_relative "../../spec_helper"
describe Spectrum::Entities::AlmaHoldings do
  before(:each) do
    @mms_id = "990020578280106381"
    @alma_holdings = JSON.parse(File.read("./spec/fixtures/alma_loans_one_holding.json"))
    @solr_bib_alma = JSON.parse(File.read("./spec/fixtures/solr_bib_alma.json"))
  end
  subject do
    described_class.new(alma: @alma_holdings, solr: Spectrum::BibRecord.new(@solr_bib_alma))
  end
  it "has working [] access" do
    expect(subject[0].class.name.to_s).to include("AlmaHolding")
  end
  it "returns holdings for #each" do
    holdings = []
    subject.each { |x| holdings.push(x.class.name.to_s) }
    expect(holdings[0]).to include("AlmaHolding")
  end
  it "has holdings" do
    expect(subject.holdings.first.class.to_s).to eq("Spectrum::Entities::AlmaHolding")
  end
  context "#find_item" do
    it "finds an item for a given barcode" do
      expect(subject.find_item("39015017893416").class.name.to_s).to eq("Spectrum::Entities::AlmaItem")
    end
    it "returns nil if barcode doesn't match" do
      expect(subject.find_item("not_a_barcode")).to be_nil
    end
  end
  context ".for(bib_record:)" do
    it "generates AlmaHoldings for given bib record" do
      stub_alma_get_request(url: "bibs/#{@mms_id}/loans", output: File.read("./spec/fixtures/alma_loans_one_holding.json"), query: {limit: 100, offset: 0})

      holdings = described_class.for(bib_record: Spectrum::BibRecord.new(@solr_bib_alma))
      expect(holdings.class.name.to_s).to eq("Spectrum::Entities::AlmaHoldings")
    end
    it "generates empty alma holdings if there aren't any" do
      @solr_bib_alma["response"]["docs"][0]["hol"] = "[]"
      holdings = described_class.for(bib_record: Spectrum::BibRecord.new(@solr_bib_alma))
      expect(holdings.empty?).to eq(true)
      expect(holdings.holdings).to eq([])
    end
  end
  context "#empty?" do
    it "is always false because AlmaHoldings only get made when there are holdings" do
      expect(subject.empty?).to eq(false)
    end
  end
end
describe Spectrum::Entities::AlmaHolding do
  before(:each) do
    @solr_json = JSON.parse(File.read("./spec/fixtures/solr_bib_alma.json"))
    @alma_loan = JSON.parse(File.read("./spec/fixtures/alma_loans_one_holding.json"))["item_loan"]
  end
  subject do
    solr_bib_record = Spectrum::BibRecord.new(@solr_json)
    solr_holding = solr_bib_record.alma_holding("22957681780006381")
    described_class.new(bib: solr_bib_record, alma_loans: @alma_loan, solr_holding: solr_holding)
  end
  it "has bib title" do
    expect(subject.title).to eq("Enhancing faculty careers : strategies for development and renewal /")
  end
  # it "has a doc_id" do
  # expect(subject.doc_id).to eq('doc_id')
  # end
  it "has holding_id" do
    expect(subject.holding_id).to eq("22957681780006381")
  end
  it "has a call number" do
    expect(subject.callnumber).to eq("LB 2331.72 .S371 1990")
  end
  it "has items" do
    expect(subject.items[0].class.to_s).to eq("Spectrum::Entities::AlmaItem")
  end
  it "has public_note" do
    expect(subject.public_note).to eq([])
  end
  it "has summary_holdings" do
    expect(subject.summary_holdings).to eq("")
  end

  context "solr process type Loan; alma has empty loan response; (i.e. item checked in today)" do
    it "has an empty due date for the item" do
    end
  end
end
