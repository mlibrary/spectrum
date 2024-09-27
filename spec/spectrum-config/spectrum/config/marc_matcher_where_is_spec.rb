require_relative "../../../spec_helper"
require_relative '../../../subfield_stub'
require_relative '../../../field_stub'

describe Spectrum::Config::MarcMatcherWhereIs do
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
    let(:cfg) { {'sub' => 'a', 'is' => ['']} }
    let(:matching_field) { FieldStub.new('a', '') }
    let(:not_matching_field) { FieldStub.new('b', '') }
    let(:not_matching_value) { FieldStub.new('a', 'not-value') }
      
    context "#match?" do
      it 'returns true when given matching field and value' do
        expect(subject.match?(matching_field)).to be(true)
      end

      it 'returns false when given not-matching field with matching value' do
        expect(subject.match?(not_matching_field)).to be(false)
      end

      it 'returns false when given matching field and not-matching value' do
        expect(subject.match?(not_matching_value)).to be(false)
      end
    end
  end
end
