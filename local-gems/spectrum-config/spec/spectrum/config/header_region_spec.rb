require_relative '../../spec_helper'
require 'spectrum/config/header_region'
require 'spectrum/config/header_component'
require 'spectrum/config/plain_header_component'


describe Spectrum::Config::HeaderRegion do
  subject { described_class.new(region_config) }

  let(:region_config) {{ 'region_descriptor'=>{ 'type' => 'plain' } }}

  let(:string_data) { "STRING" }
  let(:array_data) { ["STRING1", "STRING2"] }

  let(:string_data_result) {
    {
      description: [{text: "STRING"}],
      region: 'region_descriptor',
    }
  }

  let(:array_data_result) {
    {
      description: [{text: "STRING1"}, {text: "STRING2"}],
      region: 'region_descriptor',
    }
  }

  context "#resolve" do
    it "returns nil when given nil" do
      expect(subject.resolve(nil)).to be(nil)
    end

    it "returns nil when given []" do
      expect(subject.resolve([])).to be(nil)
    end

    it "returns nil when given [nil]" do
      expect(subject.resolve([nil])).to be(nil)
    end

    it "returns nil when given ['']" do
      expect(subject.resolve([''])).to be(nil)
    end

    it "returns string_data_result when given string_data" do
      expect(subject.resolve(string_data)).to eq(string_data_result)
    end

    it "returns string_data_result when given string_data" do
      expect(subject.resolve(array_data)).to eq(array_data_result)
    end
  end
end
