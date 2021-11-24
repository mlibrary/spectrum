require_relative '../../rails_helper'
require 'spectrum/config/metadata_component'
require 'spectrum/config/plain_metadata_component'

describe Spectrum::Config::PlainMetadataComponent do
  subject { described_class.new('Name', {'type' => 'plain'}) }
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
  context "#resolve" do
    it "returns nil when given nil" do
      expect(subject.resolve(nil)).to be(nil)
    end

    it "returns nil when given []" do
      expect(subject.resolve([])).to be(nil)
    end

    it "returns nil when given [nil]" do
      expect(subject.resolve([''])).to be(nil)
    end

    it "returns nil when given ['']" do
      expect(subject.resolve([''])).to be(nil)
    end

    it "returns data when given true" do
      expect(subject.resolve(true)).to eq(true_result)
    end

    it "returns data when given false" do
      expect(subject.resolve(false)).to eq(false_result)
    end

    it "returns data when given a metadata component hash" do
      expect(subject.resolve(true_result)).to eq(true_result)
    end
  end
end
