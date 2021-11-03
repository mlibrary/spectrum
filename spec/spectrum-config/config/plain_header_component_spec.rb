require_relative '../../rails_helper'
require 'spectrum/config/header_component'
require 'spectrum/config/plain_header_component'

describe Spectrum::Config::PlainHeaderComponent do
  subject { described_class.new('REGION', {'type' => 'plain'}) }

  let(:string_data) { "STRING" }

  let(:data) {{
                region: 'REGION',
                description: 'DESCRIPTION',
              }}

  let(:data_result) {{
                       region: 'REGION',
                       description: 'DESCRIPTION',
                     }}

  let(:string_data_result) {{
                       region: 'REGION',
                       description: [{text: "STRING"}],
                     }}

  let(:data_full) {{
                     region: 'REGION',
                     description: [{text: 'DESCRIPTION'}]
                   }}

  let(:data_full_result) {{
                            region: 'REGION',
                            description: [{text: 'DESCRIPTION'}]
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

    it "returns data when given a header component hash" do
      expect(subject.resolve(data)).to eq(data_result)
    end

    it "returns data when given a header component hash" do
      expect(subject.resolve(string_data)).to eq(string_data_result)
    end

    it "returns data when given full header component data" do
      expect(subject.resolve(data_full)).to eq(data_full_result)
    end
  end
end
