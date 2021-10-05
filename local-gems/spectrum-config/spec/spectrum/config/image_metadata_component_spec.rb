require_relative '../../spec_helper'
require 'spectrum/config/metadata_component'
require 'spectrum/config/image_metadata_component'

describe Spectrum::Config::ImageMetadataComponent do
  subject { described_class.new('Name', config) }
  let(:config) {{
    'text_field' => 'text',
    'image_field' => 'image',
  }}
  let(:data) {
    [
      { 'uid' => 'text', name: 'text', 'value' => 'TEXT'},
      { 'uid' => 'image', name: 'image', 'value' => 'IMAGE'},
    ]
  }

  let(:result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [{
      text: 'TEXT',
      image: 'IMAGE',
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
