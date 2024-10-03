# frozen_string_literal: true

require_relative "../../spec_helper"

describe Spectrum::Holding::Action, ".for" do
  before(:each) do
    @item = instance_double(Spectrum::Entities::AlmaItem, :item_policy => "01", :library => "SHAP", :location => "NONE", "etas?" => false, :process_type => nil, :can_reserve? => false, :record_has_finding_aid => false, :fullrecord => {}, :barcode => "somebarcode", :in_game? => false)
  end
  subject do
    described_class.for(@item)
  end
  it "returns NoAction" do
    allow(@item).to receive("library").and_return("AAEL")
    allow(@item).to receive("item_policy").and_return("05")
    expect(subject.class.to_s).to eq("Spectrum::Holding::NoAction")
  end
  it "returns FindingAidAction" do
    allow(@item).to receive("record_has_finding_aid").and_return(true)
    expect(subject.class.to_s).to eq("Spectrum::Holding::FindingAidAction")
  end
  it "returns RequestThisAction if given RequestThis arguments" do
    allow(@item).to receive("can_reserve?").and_return(true)
    expect(subject.class.to_s).to eq("Spectrum::Holding::RequestThisAction")
  end
  it "returns GetThisAction if it doesn't fall into the others" do
    expect(subject.class.to_s).to eq("Spectrum::Holding::GetThisAction")
  end
end
