require_relative "../../rails_helper"

describe Spectrum::Presenters::ElectronicItem do
  context "E56 or 856 electronic item" do
    before(:each) do
      @item = instance_double(Spectrum::BibRecord::ElectronicHolding, link: "Link", link_text: "Link Text", description: "Description", note: "Note", status: "Available", library: "ELEC")
    end
    subject do
      described_class.for(@item)
    end
    it "returns a regular electronic item when status is 'Available'" do
      expect(subject.class).to eq(described_class)
    end
    it "returns unavailble electronic item when status is 'Not Available'" do
      allow(@item).to receive(:status).and_return("Not Available")
      expect(subject.class).to eq(Spectrum::Presenters::ElectronicItem::UnavailableElectronicItem)
    end
    it "has appropriate available item #to_a" do
      expect(subject.to_a).to eq([{text: "Link Text", href: "Link"}, {text: "Description"}, {text: "Note"}])
    end
    it "has appropriate unavailable item #to_a" do
      allow(@item).to receive(:status).and_return("Not Available")
      expect(subject.to_a).to eq(
        [
          {text: "Coming soon."},
          {text: "Link will update when access is available. Description"},
          {text: "Note"}
        ]
      )
    end
  end
  context "Alma Digital electronic item" do
    before(:each) do
      @item = instance_double(Spectrum::BibRecord::DigitalHolding, link: "Link", link_text: "Link text", library: "ALMA_DIGITAL", public_note: "Public note", delivery_description: "Delivery description", label: "Label")
    end
    subject do
      described_class.for(@item)
    end
    it "returns a digital electronic item present when library is ALMA Digital" do
      expect(subject.class).to eq(Spectrum::Presenters::ElectronicItem::DigitalItem)
    end
    it "has appropriate digital item #to_a" do
      expect(subject.to_a).to eq([
        {text: "Link text", href: "Link"},
        {text: "Label"},
        {text: "Delivery description; Public note"}
      ])
    end
    context "source" do
      it "handles empty public note" do
        allow(@item).to receive(:public_note).and_return(nil)
        expect(subject.source).to eq("Delivery description")
      end
      it "handles nil delivery_description" do
        allow(@item).to receive(:delivery_description).and_return(nil)
        expect(subject.source).to eq("Public note")
      end
      it "handles both nil public note and delivery description" do
        allow(@item).to receive(:public_note).and_return(nil)
        allow(@item).to receive(:delivery_description).and_return(nil)
        expect(subject.source).to eq("")
      end
    end
  end
end
