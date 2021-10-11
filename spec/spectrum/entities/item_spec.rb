require_relative '../../spec_helper'
describe Spectrum::Entities::GetHoldingsItem do
  before(:each) do
    @doc_id = "000311635"
    @holdings = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))[@doc_id]
  end
  context ".for" do
    it "returns a HathiItem" do
      holding = Spectrum::Entities::Holding.for(@doc_id, @holdings[0])
      item = described_class.for(holding, @holdings[0]["item_info"][0])
      expect(item.class.name.to_s).to include('HathiItem')
    end
    it "returns a MirlynItem" do
      holding = Spectrum::Entities::Holding.for(@doc_id, @holdings[1])
      item = described_class.for(holding, @holdings[0]["item_info"][1])
      expect(item.class.name.to_s).to include('MirlynItem')
    end
  end
end
describe Spectrum::Entities::MirlynItem do
  subject do
    doc_id = "000311635"
    holding = instance_double(Spectrum::Entities::Holding)
    item = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))[doc_id][1]["item_info"][0]
    described_class.new(holding, item)
  end
  it "has a barcode" do
    expect(subject.barcode).to eq("39015009714562")
  end
end
describe Spectrum::Entities::HathiItem do
  subject do
    doc_id = "000311635"
    holding = instance_double(Spectrum::Entities::Holding)
    item = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))[doc_id][0]["item_info"][0]
    described_class.new(holding, item)
  end
  it "has a barcode" do
    expect(subject.source).to eq("Indiana University")
  end
  it "has rights" do
    expect(subject.rights).to eq("ic")
  end
  it "has an id" do
    expect(subject.id).to eq("inu.30000042758924")
  end
end
