require_relative '../../spec_helper'

require 'spectrum/config/aggregator'
require 'spectrum/config/collapsing_aggregator'
require 'spectrum/config/list_aggregator'

describe Spectrum::Config::ListAggregator do
  context "#add / #to_value" do
    let(:metadata) { nil }
    let(:field) { 'field' }
    let(:subfield1) { Struct.new(:value).new('value1') }
    let(:subfield2) { Struct.new(:value).new('value2') }
    let(:results) { ['value1', 'value2'] }

    subject do
      described_class.new('list').tap do |aggregator|
        aggregator.add(metadata, field, subfield1)
        aggregator.add(metadata, field, subfield2)
      end
    end

    it 'returns a list' do
      expect(subject.to_value).to eq(results)
    end
  end
end

