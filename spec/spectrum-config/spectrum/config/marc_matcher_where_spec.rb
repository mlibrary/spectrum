require_relative '../../../rails_helper'
require 'spectrum/config/marc_matcher_where_clause'
require 'spectrum/config/marc_matcher_where'

describe Spectrum::Config::MarcMatcherWhere do
  context "Configured with nil" do
    subject { described_class.new(nil) }
    context "#match?" do
      it "returns true when given nil" do
        expect(subject.match?(nil)).to be(true)
      end
    end
  end

  context "Configured with []" do
    subject { described_class.new([]) }
    context "#match?" do
      it "returns true when given nil" do
        expect(subject.match?(nil)).to be(true)
      end
    end
  end

  context "Configured with data" do
    subject { described_class.new(cfg) }
    let(:cfg) { [{'sub' => 'a', 'is' => ['']}] }
    let(:field) { nil }
    context "#match?" do
      it 'returns false when given nil' do
        expect(subject.match?(field)).to be(false)
      end
    end
  end
end
