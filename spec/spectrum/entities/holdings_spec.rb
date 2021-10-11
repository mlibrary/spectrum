require_relative '../../spec_helper'

describe Spectrum::Entities::Holdings do
  let(:solr) { File.read('./spec/fixtures/hurdy_solr.json') }
  let(:getHoldings) { File.read('./spec/fixtures/hurdy_gurdy_getHoldings.json')}
  let(:source_dbl) { double('Source', url: 'http://localhost/solr/biblio', holdings: 'http://mirlyn/getHoldings.pl?id=', driver: 'RSolr') }
  let(:request) {Spectrum::Request::Holdings.new({id: '000311635'}) } 

  subject do
    holdings = JSON.parse(getHoldings)
    described_class.new(holdings)
  end
  it "returns a Holdings object" do
    expect(subject.class.name.to_s).to eq("Spectrum::Entities::Holdings")
  end
  it "has holdings array wight Hathi and Mirlyn Holdings" do 
    holdings = subject.holdings
    expect(holdings[0].class.name).to include('HathiHolding')
    expect(holdings[1].class.name).to include('MirlynHolding')
  end
  it "has a doc_id" do
    expect(subject.doc_id).to eq("000311635")
  end
  it "returns holdings for #each" do
    holdings = []
    subject.each{|x| holdings.push(x.class.name.to_s) }
    expect(holdings[0]).to include('HathiHolding')
    expect(holdings[1]).to include('MirlynHolding')
  end
  context "#find_item" do 
    it "returns item for a barcode" do
      item = subject.find_item("39015009714562")
      expect(item.class.name.to_s).to include('MirlynItem')
    end
    it "returns empty_item for wrong barcode" do 
      item = subject.find_item("blah")
      expect(item.class.name.to_s).to include('EmptyItem')
    end
  end
  context "#find_item_by_item_key" do 
    it "returns item for an item key" do
      item = subject.find_item_by_item_key("000311635000010")
      expect(item.class.name.to_s).to include('MirlynItem')
    end
    it "returns empty_item for wrong item key" do 
      item = subject.find_item_by_item_key("blah")
      expect(item.class.name.to_s).to include('EmptyItem')
    end
  end
  context "#hathi_holdings" do
    it "returns hathi holdings array" do
      expect(subject.hathi_holdings.class.name.to_s).to eq("Array")
    end
  end
  context ".for" do

    before(:each) do
      @gh_url = "#{source_dbl.holdings}#{request.id}"
    end
    subject do
      described_class.for(source_dbl, request)     
    end
    it "returns an Entities:Holdings instance" do
      stub_request(:get, @gh_url).to_return(body: getHoldings, status: 200, headers: {content_type: 'application/json'})
      expect(subject.class.name.to_s).to eq("Spectrum::Entities::Holdings")
    end
    it "returns an empty Holdings object on bad response" do
      stub_request(:get, @gh_url).to_return(body: '{}', status: 500, headers: {content_type: 'application/json'})
      expect(subject.empty?).to be(true)
    end

    it "retruns an empty Holdings object on an empty object" do
      stub_request(:get, @gh_url).to_return(body: '{}', status: 200, headers: {content_type: 'application/json'})
      expect(subject.empty?).to be(true)
    end
  end
end
describe Spectrum::Entities::Holding do
  subject do
    mirlyn_holding = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))["000311635"][1]
    described_class.new("000311635", mirlyn_holding)
  end
  it "has a callnumber" do
    expect(subject.callnumber).to eq('ML760 .P18')
  end
  it "has a sub_library" do
    expect(subject.sub_library).to eq('MUSIC')
  end
  it "has a collection" do
    expect(subject.collection).to be_nil
  end
  it "has an info_link" do
    expect(subject.info_link).to eq('http://www.lib.umich.edu/location/music-library/unit/39')
  end
  it "has a location" do
    expect(subject.location).to be_nil
  end
  it "has a status" do
    expect(subject.status).to eq('On shelf')
  end
  it "has items" do
    expect(subject.items.count).to eq(1)
  end
  context ".for" do
    before(:each) do
      @holding = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))["000311635"]
    end
    it "returns a HathiHolding for a HathiItem" do
      expect(described_class.for("000311635", @holding[0]).class.name.to_s).to include('HathiHolding')
    end
    it "returns a MirlynHolding for a MirlynItem" do
      expect(described_class.for("000311635", @holding[1]).class.name.to_s).to include('MirlynHolding')
    end
  end
end
describe Spectrum::Entities::HathiHolding do
  subject do
    hathi_holding = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))["000311635"][0]
    described_class.new("000311635",hathi_holding)
  end
  it "has an id" do
    expect(subject.id).to eq('inu.30000042758924')
  end

end
describe Spectrum::Entities::MirlynHolding do
  subject do
    mirlyn_holding = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))["000311635"][1]
    described_class.new("000311635", mirlyn_holding)
  end
  it "has a holding_id" do
    expect(subject.holding_id).to eq('000671336')
  end
end

