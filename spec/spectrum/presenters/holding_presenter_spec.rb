describe Spectrum::Presenters::HoldingPresenter do
  before(:each) do
    @holding = double(library: "HATCH")
  end

  context "self.for" do
    subject do
      described_class.for(@holding)
    end
    it "returns a HathiHoldingPresenter when the library is \"HathiTrust Digital Library\"" do
      allow(@holding).to receive(:library).and_return("HathiTrust Digital Library")
      expect(subject.class.to_s).to match(/HathiHoldingPresenter/)
    end
    it "returns an EmptyHoldingPresenter when the library is \"EMPTY\"" do
      allow(@holding).to receive(:library).and_return("EMPTY")
      expect(subject.class.to_s).to match(/EmptyHoldingPresenter/)
    end
    it "returns ElectronicHoldingPresenter when the library is ELEC" do
      allow(@holding).to receive(:library).and_return("ELEC")
      expect(subject.class.to_s).to match(/ElectronicHoldingPresenter/)
    end
    it "returns an AlmaHoldingPresenter" do
      expect(subject.class.to_s).to match(/AlmaHoldingPresenter/)
    end
  end
end
