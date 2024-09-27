require_relative "../../../spec_helper"
require_relative '../../../subfield_stub'
require_relative '../../../field_stub'

describe Spectrum::Config::MarcMatcherWhereExists do
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
    let(:cfg) { {'sub' => 'a', 'exists' => true} }
    let(:matching_field) { FieldStub.new('a', '') }
    let(:not_matching_field) { FieldStub.new('b', '') }
      
    context "#match?" do
      it 'returns true when given match' do
        expect(subject.match?(matching_field)).to be(true)
      end

      it 'returns false when given not-match' do
        expect(subject.match?(not_matching_field)).to be(false)
      end
    end
  end
end
