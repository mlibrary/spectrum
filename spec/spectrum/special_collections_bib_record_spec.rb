require_relative '../rails_helper'
describe Spectrum::SpecialCollectionsBibRecord do
  before(:each) do
    @scrc_bib = File.read('./spec/fixtures/spec_rda_bib.json')
  end
  subject do
    bib_record = Spectrum::BibRecord.new(JSON.parse(@scrc_bib))
    described_class.new(bib_record.fullrecord)
  end
  it "has a title" do
    expect(subject.title).to eq('Universal Declaration of Human Rights /')
  end
  it "has an author" do
    expect(subject.author).to eq('Stern, Meredith,')
  end
  it "has a genre" do
    expect(subject.genre).to eq('BOOK')
  end
  it "has a date" do
    expect(subject.date).to eq('[2017]')
  end
  it "has an edition" do
    expect(subject.edition).to eq('')
  end
  it "has a publisher" do
    expect(subject.publisher).to eq('[Meredith Stern],')
  end
  it "has a place" do
    expect(subject.place).to eq('[Providence, Rhode Island] :')
  end
  it "has an extent" do
    expect(subject.extent).to eq('32 leaves : illustrations ; 48 x 33 cm, in portfolio 50 x 35 x 2 cm')
  end
end

