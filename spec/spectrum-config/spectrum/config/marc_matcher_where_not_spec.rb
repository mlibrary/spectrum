require_relative "../../../spec_helper"
require_relative '../../../subfield_stub'
require_relative '../../../field_stub'

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
    let(:not_matching_value) { FieldStub.new('a', 'not-value') }
      
    context "#match?" do
      it 'returns false when given the thing to not match' do
        expect(subject.match?(matching_field)).to be(false)
      end

      it 'returns true when not given the field to not-match' do
        expect(subject.match?(not_matching_field)).to be(true)
      end

      it 'returns true when given the field to not-match with a different value' do
        expect(subject.match?(not_matching_value)).to be(true)
      end
    end
  end
end
