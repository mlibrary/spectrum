require_relative "../../../spec_helper"

describe Spectrum::Config::IconMetadataComponent do
  subject { described_class.new('Name', {'type' => 'icon'}) }

  let(:true_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [{text: 'true'}]
  }}

  let(:false_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [{text: 'false'}]
  }}

  let(:book_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [{text: 'Book', icon: 'book'}]
  }}

  context "#resolve" do
    it "returns nil when given nil" do
      expect(subject.resolve(nil)).to be(nil)
    end

    it "returns a text description when given true" do
      expect(subject.resolve(true)).to eq(true_result)
    end

    it "returns a text description when given false" do
      expect(subject.resolve(false)).to eq(false_result)
    end

    it "returns nil when given []" do
      expect(subject.resolve([])).to be(nil)
    end

    it "returns an icon  when given 'Book'" do
      expect(subject.resolve('Book')).to eq(book_result)
    end
  end
end
