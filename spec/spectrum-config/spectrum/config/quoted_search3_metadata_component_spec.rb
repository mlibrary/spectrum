require_relative "../../../rails_helper"
require "spectrum/config/metadata_component"
require "spectrum/config/quoted_search3_metadata_component"

describe Spectrum::Config::QuotedSearch3MetadataComponent do
  subject { described_class.new("Name", config) }
  let(:config) {
    {
      "scope" => "SCOPE",
      "variant" => "fielded"
    }
  }
  let(:data) {
    ["Subject one", "Subject two -- Subsubject"]
  }

  let(:result) {
    {
      term: "Name",
      termPlural: "Names",
      description: [
        {
          text: "Subject one",
          search: {
            type: "fielded",
            scope: "SCOPE",
            value: '"Subject one"'
          }
        },
        {
          text: "Subject two -- Subsubject",
          search: {
            type: "fielded",
            scope: "SCOPE",
            value: '"Subject two Subsubject"'
          }
        }
      ]
    }
  }
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
