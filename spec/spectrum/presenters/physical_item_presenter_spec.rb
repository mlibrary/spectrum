require_relative "../../spec_helper"

describe Spectrum::Presenters::PhysicalItem, "to_a" do
  before(:each) do
    @to_a_init = {
      action: instance_double(Spectrum::Holding::Action, finalize: nil)
    }
    @item = double("Spectrum::Entities::AlmaItem", :callnumber => "call_number", :inventory_number => nil, "process_type" => nil, :item_policy => "01", :requested? => false, :in_reserves? => false, :in_unavailable_temporary_location? => false, :description => nil, :temp_location? => false, :can_reserve? => false, :fulfillment_unit => "General", :library => "HATCH", :location => "GRAD", :in_deep_storage? => false)
  end
  subject do
    described_class.new(@item).to_a(**@to_a_init)
  end
  it "returns an array" do
    expect(subject.class.name).to eq("Array")
  end
  it "returns appropriate status" do
    expect(subject[2]).to eq({text: "On shelf", intent: "success", icon: "check_circle"})
  end
  it "returns call number" do
    expect(subject[3]).to eq({text: @item.callnumber})
  end
  it "handles Video call number" do
    allow(@item).to receive(:callnumber).and_return("VIDEO call_number")
    allow(@item).to receive(:inventory_number).and_return("12345")
    expect(subject[3]).to eq({text: "VIDEO call_number - 12345"})
  end
  it "handles nil call_number" do
    allow(@item).to receive(:callnumber).and_return(nil)
    expect(subject[3]).to eq({text: "N/A"})
  end
end
