require_relative "../../rails_helper"
describe Spectrum::Entities::GetThisWorkOrderOption do
  before(:each) do
    @item = double("Spectrum::Decorators::PhysicalItemDecorator", location: "HATCH", process_type: "WORK_ORDER_DEPARTMENT", barcode: "BARCODE")
    @alma_item = JSON.parse(File.read("./spec/fixtures/get_this/alma_work_order_item.json"))
  end
  subject do
    stub_alma_get_request(url: "items", output: @alma_item.to_json, query: {item_barcode: "BARCODE"})
    described_class.for(@item)
  end
  context ".for" do
    it "returns a GetThisWorkOrderOption object for an item with a WORK_ORDER_DEPARTMENT process type" do
      expect(subject.class.to_s).to include("GetThisWorkOrderOption")
    end
    it "returns a GetThisWorkOrderNotApplicable object for an item with a non work order process type" do
      allow(@item).to receive(:process_type).and_return("IN_TRANSIT")
      expect(subject.class.to_s).to include("GetThisWorkOrderNotApplicable")
    end
    it "returns a GetThisWorkOrderNotApplicable if the api response returns not 200" do
      stub_alma_get_request(url: "items", query: {item_barcode: "BARCODE"}, status: 500)
      expect(described_class.for(@item).class.to_s).to include("GetThisWorkOrderNotApplicable")
    end
  end
  context "#in_labeling?" do
    it "is true when an item is in labeling" do
      expect(subject.in_labeling?).to eq(true)
    end
    it "is false when no item that isn't in labeling" do
      @alma_item["item_data"]["work_order_type"]["value"] = "NOT_A_REQUESTABLE_WORK_ORDER_DEPT"
      expect(subject.in_labeling?).to eq(false)
    end
  end
  context "in_international_studies_acquisitions_technical_services?" do
    it "is true when an item is in international studies and is in the AqcWork Order" do
      @alma_item["item_data"]["work_order_type"]["value"] = "AcqWorkOrder"
      @alma_item["item_data"]["location"]["value"] = "IS-SEEES"
      expect(subject.in_international_studies_acquisitions_technical_services?).to eq(true)
    end
    it "is false for an AcqWorkOrder item not in IS-SEES" do
      @alma_item["item_data"]["work_order_type"]["value"] = "AcqWorkOrder"
      expect(subject.in_international_studies_acquisitions_technical_services?).to eq(false)
    end
    it "is false for an item is IS-SEES that isn't in the AcqWorkOrder" do
      @alma_item["item_data"]["location"]["value"] = "IS-SEEES"
      expect(subject.in_international_studies_acquisitions_technical_services?).to eq(false)
    end
  end
end
describe Spectrum::Entities::GetThisWorkOrderOption::GetThisWorkOrderNotApplicable do
  subject do
    described_class.new
  end
  context "#in_international_studies_acquisitions_technical_services?" do
    it "is false" do
      expect(subject.in_international_studies_acquisitions_technical_services?).to eq(false)
    end
  end
  context "#in_labeling?" do
    it "is false" do
      expect(subject.in_labeling?).to eq(false)
    end
  end
end
