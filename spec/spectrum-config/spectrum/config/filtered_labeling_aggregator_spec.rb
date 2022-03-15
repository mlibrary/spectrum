require_relative '../../../rails_helper'

require 'spectrum/config/aggregator'
require 'spectrum/config/filtered_labeling_aggregator'

describe Spectrum::Config::FilteredLabelingAggregator do
  context "When initialized this way" do

    let(:metadata) do
       SpecData.load_json('metadata.json', __FILE__).deep_symbolize_keys 
    end

    let(:marc) do
      SpecData.load_marcxml('record.marcxml', __FILE__)
    end

    let(:results) do
      SpecData.load_json('results.json', __FILE__).map do |item|
        item.map(&:deep_symbolize_keys)
      end
    end

    subject do
      described_class.new('filtered_labeling').tap do |aggregator|
        field = marc.first['100']
        field.subfields.each do |subfield|
          next if ['0','1'].include?(subfield.code)
          aggregator.add(metadata, field, subfield)
        end
      end
    end

    context "#to_value" do
      it 'filters' do
        expect(subject.to_value).to eq(results)
      end
    end
  end
end
