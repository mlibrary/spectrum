require_relative '../../spec_helper'
describe Spectrum::Holding::FindingAidAction do
  before(:each) do
    @item = instance_double(Spectrum::Entities::AlmaItem, record_has_finding_aid: true)
  end
  context "::match?" do
    subject do
      described_class.match?(@item)
    end
    it "matches when record_has_finding_aid" do
      expect(subject).to eq(true)
    end
    it "does not match when record doe not have finding aid" do
      allow(@item).to receive(:record_has_finding_aid).and_return(false)
      expect(subject).to eq(false)
    end
  end
end
