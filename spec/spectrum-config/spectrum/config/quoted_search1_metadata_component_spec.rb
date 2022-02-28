require_relative '../../../rails_helper'
require 'spectrum/config/metadata_component'
require 'spectrum/config/quoted_search1_metadata_component'

describe Spectrum::Config::QuotedSearch1MetadataComponent do
  subject { described_class.new('Name', config) }
  let(:config) {{
    'type' => 'quoted_search1',
    'variant' => 'filtered',
    'scope' => 'SCOPE',
  }}
  let(:true_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [
      {
        text: true,
        search: {
          type: 'filtered',
          scope: 'SCOPE',
          value: '"true"',
        }
      }
    ]
  }}
  let(:false_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [
      {
        text: false,
        search: {
          type: 'filtered',
          scope: 'SCOPE',
          value: '"false"',
        }
      }
    ]
  }}
  context "#resolve" do
    it "returns nil when given nil" do
      expect(subject.resolve(nil)).to be(nil)
    end

    it "returns nil when given []" do
      expect(subject.resolve([])).to be(nil)
    end

    it "returns data when given true" do
      expect(subject.resolve(true)).to eq(true_result)
    end

    it "returns data when given false" do
      expect(subject.resolve(false)).to eq(false_result)
    end
  end
end
