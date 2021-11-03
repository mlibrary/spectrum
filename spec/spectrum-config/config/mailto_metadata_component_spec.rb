require_relative '../../rails_helper'
require 'spectrum/config/metadata_component'
require 'spectrum/config/mailto_metadata_component'

describe Spectrum::Config::MailtoMetadataComponent do
  subject { described_class.new('Name', {'type' => 'mailto'}) }
  let(:true_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [{text: 'true', href: 'mailto:true'}]
  }}
  let(:false_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [{text: 'false', href: 'mailto:false'}]
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
