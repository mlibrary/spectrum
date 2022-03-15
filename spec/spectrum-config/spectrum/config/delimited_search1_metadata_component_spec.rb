require_relative '../../../rails_helper'
require 'spectrum/config/metadata_component'
require 'spectrum/config/delimited_search1_metadata_component'

describe Spectrum::Config::DelimitedSearch1MetadataComponent do
  subject { described_class.new('Name', config) }
  let(:config) {{
    'type' => 'delimited_search1',
    'variant' => 'filtered',
    'scope' => 'SCOPE',
    'delimiter' => '|'
  }}
  let(:true_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [[
      {
        text: 'true',
        search: {
          type: 'filtered',
          scope: 'SCOPE',
          value: 'true'
        }
      }
    ]]
  }}
  let(:false_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [[
      {
        text: 'false',
        search: {
          type: 'filtered',
          scope: 'SCOPE',
          value: 'false'
        }
      }
    ]]
  }}
  let(:list_result) {{
    term: 'Name',
    termPlural: 'Names',
    description: [[
      {
        text: 'false',
        search: {
          type: 'filtered',
          scope: 'SCOPE',
          value: 'false'
        }
      },
      {
        text: 'true',
        search: {
          type: 'filtered',
          scope: 'SCOPE',
          value: 'true'
        }
      }
    ]]
  }}
  context "#resolve" do
    it "returns nil when given nil" do
      expect(subject.resolve(nil)).to be(nil)
    end

    it "returns nil when given []" do
      expect(subject.resolve([])).to be(nil)
    end

    it "returns one item when given true" do
      expect(subject.resolve(true)).to eq(true_result)
    end

    it "returns one item when given false" do
      expect(subject.resolve(false)).to eq(false_result)
    end
    it "returns a list when given false" do
      expect(subject.resolve('false|true')).to eq(list_result)
    end
  end
end
