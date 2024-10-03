require_relative "../../../spec_helper"

describe Spectrum::Config::QuotedSearch2MetadataComponent do
  subject { described_class.new('Name', config) }
  let(:config) {{
    'scope' => 'SCOPE',
    'variant' => 'filtered',
    'text_field' => 'display',
    'value_field' => 'search',
  }}
  let(:data) {
    [[
      { uid: 'display', name: 'display', value: 'TEXT'},
      { uid: 'search', name: 'search', value: 'VALUE'},
    ]]
  }

  let(:result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [{
      text: 'TEXT',
      search: {
        type: 'filtered',
        scope: 'SCOPE',
        value: '"VALUE"',
      }
    }],
  }}
  context "#resolve" do
    it "returns nil when given nil" do
      expect(subject.resolve(nil)).to be(nil)
    end

    it "returns nil when given true" do
      expect(subject.resolve(true)).to be(nil)
    end

    it "returns nil when given false" do
      expect(subject.resolve(false)).to be(nil)
    end

    it "returns nil when given []" do
      expect(subject.resolve([])).to be(nil)
    end

    it "returns a link when given data" do
      expect(subject.resolve(data)).to eq(result)
    end
  end
end
