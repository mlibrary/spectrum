require_relative '../../../rails_helper'

require 'spectrum/config/marc_matcher'

describe Spectrum::Config::MarcMatcher do
  context "#metadata" do
    context "When configured with an empty hash" do
      let(:cfg) {{}}
      subject { described_class.new(cfg) }
      let(:results) {{ label: "  ", join: nil, filters: [], prefix: '', suffix: '' }}

      it "returns appropriate defaults" do
        expect(subject.metadata).to eq(results)
      end
    end

    context "when configured with label, join, filters: " do
      let(:cfg) {{'label' => 'LABEL', 'join' => 'JOIN', 'filters' => [{'attr'=>'FILTER_ATTR'}]}}
      subject { described_class.new(cfg) }
      let(:results) do
        {
          label: 'LABEL',
          join:  'JOIN',
          filters: [{attr: 'FILTER_ATTR'}],
          prefix: '',
          suffix: '',
        }
      end

      it "returns label, join, filters" do
        expect(subject.metadata).to eq(results)
      end
    end

  end
end
