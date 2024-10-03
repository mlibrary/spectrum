require_relative "../../spec_helper"
describe Spectrum::Entities::GetThisOption do
  before(:each) do
    @patron = instance_double(Spectrum::Entities::AlmaUser)
    @item = double("Spectrum::Decorators::PhysicalItemDecorator")
    # Spectrum::Entities::GetThisOptions.configure('spec/fixtures/new_get_this_policy.yml')
    Spectrum::Entities::GetThisOptions.configure("config/get_this.yml")
    Spectrum::Entities::LocationLabels.configure("config/location_labels.yml")
  end
  def option_for(field:, value:)
    Spectrum::Entities::GetThisOptions.all.find { |x| x.dig(*field) == value }
  end
  context "No form" do
    subject do
      option = option_for(field: ["label"], value: "Log in to see more options")
      described_class.for(option: option, patron: @patron, item: @item)
    end
    it "returns a GetThisOption" do
      expect(subject.class.to_s).to eq("Spectrum::Entities::GetThisOption")
    end
    it "has a proper looking form" do
      expect(subject.form).to eq(JSON.parse(File.read("./spec/fixtures/get_this/no_form.json")))
    end
  end
  context "Link" do
    subject do
      option = option_for(field: ["form", "type"], value: "link")
      described_class.for(option: option, patron: @patron, item: @item)
    end
    it "returns a GetThisOption::Link" do
      expect(subject.class.to_s).to eq("Spectrum::Entities::GetThisOption::Link")
    end
    it "has a proper looking form" do
      expect(subject.form).to eq(JSON.parse(File.read("./spec/fixtures/get_this/link.json")))
    end
  end
  context "Alma Hold" do
    before(:each) do
      @base_form = JSON.parse(File.read("./spec/fixtures/get_this/alma_hold.json"))
      allow(@item).to receive(:mms_id).and_return("MMS_ID")
      allow(@item).to receive(:holding_id).and_return("HOLDING_ID")
      allow(@item).to receive(:item_id).and_return("ITEM_ID")
    end
    subject do
      option = option_for(field: ["form", "type"], value: "alma_hold")
      described_class.for(option: option, patron: @patron, item: @item, now: DateTime.parse("2022-10-03"))
    end
    it "returns an alma hold" do
      expect(subject.class.to_s).to include("AlmaHold")
    end
    it "has a proper looking form for default item" do
      allow(@item).to receive(:in_acq?).and_return(false)
      @base_form["fields"][3]["value"] = "2022-12-03"
      expect(subject.form).to eq(@base_form)
    end
    it "has a proper looking form with year long default for acq item" do
      allow(@item).to receive(:in_acq?).and_return(true)
      @base_form["fields"][3]["value"] = "2023-10-03"
      expect(subject.form).to eq(@base_form)
    end
  end
  context "ILLiad Hold" do
    subject do
      option = option_for(field: ["form", "type"], value: "illiad_request")
      described_class.for(option: option,
        patron: @patron, item: @item)
    end
    it "returns an ILLiadRequest" do
      expect(subject.class.to_s).to include("ILLiadRequest")
    end
    it "has a proper looking form" do
      allow(@item).to receive(:accession_number).and_return("ACCESSION NUMBER")
      allow(@item).to receive(:isbn).and_return("ISBN")
      allow(@item).to receive(:title).and_return("TITLE")
      allow(@item).to receive(:author).and_return("AUTHOR")
      allow(@item).to receive(:date).and_return("DATE")
      allow(@item).to receive(:pub).and_return("PUB")
      allow(@item).to receive(:place).and_return("PLACE")
      allow(@item).to receive(:callnumber).and_return("CALLNUMBER")
      allow(@item).to receive(:edition).and_return("EDITION")
      allow(@item).to receive(:location_for_illiad).and_return("LOCATION")
      allow(@item).to receive(:barcode).and_return("BARCODE")
      allow(@item).to receive(:oclc).and_return("OCLC")
      allow(@item).to receive(:cited_title).and_return("CITED_TITLE")
      expect(subject.form).to eq(JSON.parse(File.read("./spec/fixtures/get_this/illiad_request.json")))
    end
  end
end
