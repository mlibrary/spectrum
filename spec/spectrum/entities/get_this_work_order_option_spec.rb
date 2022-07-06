require_relative '../../rails_helper'
describe Spectrum::Entities::GetThisWorkOrderOption do
  before(:each) do
     @item = double('Spectrum::Decorators::PhysicalItemDecorator', location: 'HATCH', process_type: false)
     @alma_item = JSON.parse(File.read('./spec/fixtures/get_this/alma_work_order_item.json'))
  end
  subject do
    described_class.for(@item)
  end
  context "#in_gettable_workorder?" do
    it "false when no process type and not gettable location" do
      expect(subject.in_gettable_workorder?).to eq(false)
    end
    it "is true when both in a work order department and it's in the correct work order department" do
      stub_alma_get_request(url: "items", output: @alma_item.to_json, query: {item_barcode: 'BARCODE'})
      allow(@item).to receive(:process_type).and_return('WORK_ORDER_DEPARTMENT')
      allow(@item).to receive(:barcode).and_return('BARCODE')
      expect(subject.in_gettable_workorder?).to eq(true)
    end
    it "is false when in the incorrect work order department" do
      @alma_item["item_data"]["work_order_type"]["value"] = "NOT_A_REQUESTABLE_WORK_ORDER_DEPT"
      stub_alma_get_request(url: "items", output: @alma_item.to_json, query: {item_barcode: 'BARCODE'})
      allow(@item).to receive(:process_type).and_return("WORK_ORDER_DEPARTMENT")
      allow(@item).to receive(:barcode).and_return("BARCODE")
      expect(subject.in_gettable_workorder?).to eq(false)
    end
  end

end
