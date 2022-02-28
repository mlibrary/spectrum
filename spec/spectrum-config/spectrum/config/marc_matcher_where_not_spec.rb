require_relative '../../../rails_helper'

require_relative '../../../subfield_stub'
require_relative '../../../field_stub'

require 'spectrum/config/marc_matcher_where_clause'
require 'spectrum/config/marc_matcher_where_not'

describe Spectrum::Config::MarcMatcherWhereNot do
  context "Configured with nil" do
    subject { described_class.new(nil) }
    context "#match?" do
      it "returns true when given nil" do
        expect(subject.match?(nil)).to be(true)
      end
    end
  end

  context "Configured with {}" do
    subject { described_class.new({}) }
    context "#match?" do
      it "returns true when given nil" do
        expect(subject.match?(nil)).to be(true)
      end
    end
  end

  context "Configured with data" do
    subject { described_class.new(cfg) }
    let(:cfg) { {'sub' => 'a', 'not' => ['']} }
    let(:matching_field) { FieldStub.new('a', '') }
    let(:not_matching_field) { FieldStub.new('b', '') }
      
    context "#match?" do
      it 'returns true when given match' do
        expect(subject.match?(matching_field)).to be(false)
      end

      it 'returns false when given not-match' do
        expect(subject.match?(not_matching_field)).to be(true)
      end
    end
  end
end
