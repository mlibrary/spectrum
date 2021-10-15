require_relative '../../rails_helper.rb'

describe  Spectrum::Presenters::ElectronicItem do
  before(:each) do
    @item = double(Spectrum::BibRecord::ElectronicHolding, link: 'Link', link_text: 'Link Text', description: 'Description', note: 'Note', status: 'Available')
  end
  subject do
    described_class.for(@item)
  end
  it "returns a regular electronic item is status is 'Available'" do
    expect(subject.class).to eq(described_class)
  end
  it "returns unavailble electronic item when status is 'Not Available'" do
    allow(@item).to receive(:status).and_return('Not Available')
    expect(subject.class).to eq(Spectrum::Presenters::ElectronicItem::UnavailableElectronicItem)
  end
  it "has appropriate available item #to_a" do
    expect(subject.to_a).to eq([{text: 'Link Text', href: 'Link'},{text: 'Description'},{text: 'Note'}])
  end
  it "has appropriate unavailable item #to_a" do
    allow(@item).to receive(:status).and_return('Not Available')
    expect(subject.to_a).to eq(
      [
        {text: 'Coming soon.'},
        {text: 'Link will update when access is available. Description'},
        {text: 'Note'}])
  end
end
