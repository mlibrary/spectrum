require_relative "../../../spec_helper"

describe Spectrum::Config::SearchBrowse2MetadataComponent do
  subject { described_class.new("Name", config) }
  let(:config) {
    {
      "browse_variant" => "browse_variant",
      "browse_text" => "browse_text",
      "quoted_browse" => false,
      "search_scope" => "search_scope",
      "search_variant" => "search_variant",
      "quoted_search" => true
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
            type: "search_variant",
            scope: "search_scope",
            value: '"Subject one"'
          },
          browse: {
            text: "browse_text",
            type: "browse_variant",
            value: "Subject one"
          }
        },
        {
          text: "Subject two -- Subsubject",
          search: {
            type: "search_variant",
            scope: "search_scope",
            value: '"Subject two Subsubject"'
          },
          browse: {
            text: "browse_text",
            type: "browse_variant",
            value: "Subject two Subsubject"
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
