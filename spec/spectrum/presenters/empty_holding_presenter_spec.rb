describe Spectrum::Presenters::HoldingPresenter::EmptyHoldingPresenter do
  subject do
    described_class.new(Spectrum::EmptyItemHolding.new(instance_double(Spectrum::BibRecord, mms_id: "MMS_ID")))
  end
  context "#type" do
    it "returns 'physical'" do
      expect(subject.type).to eq("physical")
    end
  end
  context "#caption" do
    it "returns 'Availability'" do
      expect(subject.caption).to eq("Availability")
    end
  end
  context "#headings" do
    it "returns array of heading text" do
      expect(subject.headings).to eq(["Action", "Description", "Status"])
    end
  end
  context "rows" do
    it "returns the expected content" do
      expect(subject.rows).to eq(
        [
          [
            {
              text: "Get This",
              to: {
                barcode: "unavailable",
                action: "get-this",
                record: "MMS_ID",
                datastore: "MMS_ID"
              }
            },
            {
              text: "Use Get This to request through Interlibrary Loan"
            },
            {
              text: "In Process",
              intent: "warning",
              icon: "warning"
            }

          ]
        ]
      )
    end
  end
end
