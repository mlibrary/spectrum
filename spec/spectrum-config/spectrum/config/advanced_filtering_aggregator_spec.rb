require_relative '../../../rails_helper'

require 'spectrum/config/aggregator'
require 'spectrum/config/advanced_filtering_aggregator'

describe Spectrum::Config::AdvancedFilteringAggregator do
  context "When initialized a new title" do

    let(:field) {
      MARC::DataField.new('785','0','0',
                          MARC::Subfield.new( 'a', 'TestAuthor'),
                          MARC::Subfield.new( 't', 'TestTitle')
                         )
    }

    let(:results){
      Array[
        Array[
          Hash[:uid => "display",
               :name => "NAME",
               :value => "TestAuthor TestTitle",
               :value_has_html => true],
          Hash[:uid => "search",
               :name => "NAME",
               :value => "author:\"(TestAuthor)\" AND title:\"(TestTitle)\"",
               :value_has_html => true]
        ]
      ]
    }

    subject do
      described_class.new('advanced_filtering').tap do |aggregator|
        aggregator.add(
          {:label=>"author", :join=>nil, :filters=>[]},
          field,
          MARC::Subfield.new(
            "a",
            "TestAuthor"
          )
        )
        aggregator.add(
          {:label=>"title", :join=>nil, :filters=>[]},
          field,
          MARC::Subfield.new(
            "t",
            "TestTitle"
          )
        )
      end
    end

    context "#to_value" do
      it 'filters' do
        expect(subject.to_value).to eq(results)
      end
    end
  end
end
