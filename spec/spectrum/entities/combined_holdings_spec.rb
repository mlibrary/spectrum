require_relative "../../spec_helper"
describe Spectrum::Entities::CombinedHoldings do
  before(:each) do
    @elec_holdings = []
    @alma_holding_dbl1 = instance_double(Spectrum::Entities::AlmaHolding)
    @alma_holding_dbl2 = instance_double(Spectrum::Entities::AlmaHolding)
    @alma_holdings_dbl = instance_double(Spectrum::Entities::AlmaHoldings,
      holdings: [@alma_holding_dbl1, @alma_holding_dbl2])

    @hathi_holding_dbl = instance_double(Spectrum::Entities::HathiHolding, "empty?" => false)
  end
  let(:mms_id) { "990020578280106381" }
  let(:bib_record) { instance_double(Spectrum::BibRecord, :mms_id => mms_id, :hathi_holding => {}, :alma_holding => @alma_holding_dbl1, "physical_holdings?" => true, :elec_holdings => @elec_holdings) }

  context ".for(source, request)" do
    it "returns combined holdings" do
      solr = File.read("./spec/fixtures/solr_bib_alma.json")
      source_dbl = double("Source", url: "http://localhost/solr/biblio", driver: "RSolr")
      request = Spectrum::Request::Holdings.new({id: mms_id})
      stub_alma_get_request(url: "bibs/#{mms_id}/loans", output: File.read("./spec/fixtures/alma_loans_one_holding.json"), query: {limit: 100, offset: 0})
      solr_req = stub_request(:get, "http://localhost/solr/biblio/select?q=id:#{mms_id}&wt=json").to_return(body: solr, status: 200, headers: {content_type: "application/json"})

      expect(described_class.for(source_dbl, request).class).to eq(described_class)
      expect(solr_req).to have_been_requested
    end
  end

  context ".for_bib" do
    it "returns combined holdings" do
      solr_bib_alma = JSON.parse(File.read("./spec/fixtures/solr_bib_alma.json"))
      actual_bib_record = Spectrum::BibRecord.new(solr_bib_alma)
      stub_alma_get_request(url: "bibs/#{mms_id}/loans", output: File.read("./spec/fixtures/alma_loans_one_holding.json"), query: {limit: 100, offset: 0})

      expect(described_class.for_bib(actual_bib_record).class).to eq(described_class)
    end
  end
  context "no Hathi Holding" do
    subject do
      allow(@hathi_holding_dbl).to receive("empty?").and_return(true)
      described_class.new(alma_holdings: @alma_holdings_dbl, hathi_holding: @hathi_holding_dbl, bib_record: bib_record)
    end
    it "does not include a Hathi Holding" do
      expect(subject.holdings.count).to eq(2)
    end
    it "has nil #hathi_holdings" do
      expect(subject.hathi_holdings).to be_nil
    end
  end
  context "no Alma Holding" do
    subject do
      described_class.new(alma_holdings: nil, hathi_holding: @hathi_holding_dbl, bib_record: bib_record)
    end
    it "does not include an Alma Holding" do
      expect(subject.holdings.count).to eq(1)
      expect(subject.hathi_holdings).not_to be_nil
    end
  end
  context "no Holdings" do
    subject do
      allow(@hathi_holding_dbl).to receive("empty?").and_return(true)
      described_class.new(alma_holdings: nil, hathi_holding: @hathi_holding_dbl, bib_record: bib_record)
    end
    it "has an Empty Holding" do
      expect(subject.holdings.count).to eq(1)
      expect(subject.holdings.first.library).to eq("EMPTY")
    end
  end

  subject do
    described_class.new(alma_holdings: @alma_holdings_dbl, hathi_holding: @hathi_holding_dbl,
      bib_record: bib_record)
  end
  it "has #hathi_holdings" do
    expect(subject.hathi_holdings).to eq([@hathi_holding_dbl])
  end
  it "has holdings" do
    expect(subject.holdings.count).to eq(3)
  end
  it "has working #each" do
    count = 0
    subject.each { |x| count += 1 }
    expect(count).to eq(3)
  end
  it "has working empty?" do
    expect(subject.empty?).to eq(false)
  end
  it "has working []" do
    expect(subject[0]).to eq(@hathi_holding_dbl)
    expect(subject[1]).to eq(@alma_holding_dbl1)
    expect(subject[2]).to eq(@alma_holding_dbl2)
  end
  it "uses alma_holdings #find_item" do
    allow(@alma_holdings_dbl).to receive(:find_item).and_return("item")
    expect(subject.find_item("barcode")).to eq("item")
  end
  it "has bib_record" do
    expect(subject.bib_record).to eq(bib_record)
  end
end
