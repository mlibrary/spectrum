require_relative "../../rails_helper"

describe Spectrum::Decorators::PhysicalItemDecorator do
  before(:each) do
    @input = {
      holding: instance_double(Spectrum::Entities::AlmaHolding),
      alma_loan: nil,
      solr_item: double("BibRecord::AlmaItem", process_type: nil, item_policy: "01", barcode: "somebarcode", fulfillment_unit: "General"),
      bib_record: instance_double(Spectrum::BibRecord)
    }
    @get_this_work_order_double = instance_double(Spectrum::Entities::GetThisWorkOrderOption,
      in_labeling?: "in_labeling",
      in_international_studies_acquisitions_technical_services?: "in_international_studies_acquisitions_technical_services",
      in_getable_acq_work_order?: false)
  end
  subject do
    item = Spectrum::Entities::AlmaItem.new(**@input)
    described_class.new(item, [], @get_this_work_order_double)
  end
  context "work order methods" do
    # mrio: both of these would be booleans, but having them return strings shows
    # that the correct path through the code is being used.
    it "responds to #in_international_studies_acquisitions_technical_services?" do
      expect(subject.in_international_studies_acquisitions_technical_services?).to eq("in_international_studies_acquisitions_technical_services")
    end
    it "responds to #not_in_international_studies_acquisitions_technical_services?" do
      expect(subject.not_in_international_studies_acquisitions_technical_services?).to eq(false)
    end
    it "responds to #in_labeling?" do
      expect(subject.in_labeling?).to eq("in_labeling")
    end

    it "responds to #not_in_labeling?" do
      expect(subject.not_in_labeling?).to eq(false)
    end
  end
  context "in_slower_pickup?" do
    it "is true when in_getable_acq_work_order?" do
      allow(@get_this_work_order_double).to receive(:in_getable_acq_work_order?).and_return(true)
      expect(subject.in_slower_pickup?).to eq(true)
    end

    it "is true when in_asia_transit? is true" do
      allow(@get_this_work_order_double).to receive(:in_getable_acq_work_order?).and_return(false)
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:location).and_return("ASIA")
      allow(@input[:solr_item]).to receive(:process_type).and_return("TRANSIT")
      expect(subject.in_slower_pickup?).to eq(true)
    end

    it "is false when neither in_getable_acq_work_order? or in_asia_transit?" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      allow(@input[:solr_item]).to receive(:location).and_return("MAIN")
      expect(subject.in_slower_pickup?).to eq(false)
    end
  end
  it "response to #not_in_slower_pickup?" do
    allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
    allow(@input[:solr_item]).to receive(:location).and_return("MAIN")
    expect(subject.not_in_slower_pickup?).to eq(true)
  end
  context "in_asia_transit?" do
    it "is true when in Asia library and process type transit" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:location).and_return("ASIA")
      allow(@input[:solr_item]).to receive(:process_type).and_return("TRANSIT")
      expect(subject.in_asia_transit?).to eq(true)
    end

    it "is false when in Asia library and does not have process type transit" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:location).and_return("ASIA")
      expect(subject.in_asia_transit?).to eq(false)
    end
    it "is false when not in Asia library and process type transit" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      allow(@input[:solr_item]).to receive(:location).and_return("MAIN")
      allow(@input[:solr_item]).to receive(:process_type).and_return("TRANSIT")
      expect(subject.in_asia_transit?).to eq(false)
    end
  end
  context "#can_scan?" do
    it "is true for a scannable material type" do
      allow(@input[:solr_item]).to receive(:material_type).and_return("BOOK")
      expect(subject.can_scan?).to eq(true)
    end
    it "is not true for a non-scannable material type" do
      allow(@input[:solr_item]).to receive(:material_type).and_return("GAME")
      expect(subject.can_scan?).to eq(false)
    end
  end
  context "#game?" do
    it "is true if the item is in SHAP GAME" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      allow(@input[:solr_item]).to receive(:location).and_return("GAME")
      expect(subject.game?).to eq(true)
    end
    it "is false if the item not in SHAP GAME" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      allow(@input[:solr_item]).to receive(:location).and_return("GAMEB")
      expect(subject.game?).to eq(false)
    end
  end
  context "#not_game?" do
    it "is true if the item is in SHAP GAME" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      allow(@input[:solr_item]).to receive(:location).and_return("GAMEB")
      expect(subject.not_game?).to eq(true)
    end
  end
  context "#etas?" do
    it "is true if bib_record says etas is true" do
      allow(@input[:bib_record]).to receive("etas?").and_return(true)
      expect(subject.etas?).to eq(true)
    end
  end
  context "#not_etas?" do
    it "is false if bib_record says etas is true" do
      allow(@input[:bib_record]).to receive("etas?").and_return(true)
      expect(subject.not_etas?).to eq(false)
    end
  end
  context "#music_pickup?" do
    it "is true if library is music" do
      allow(@input[:solr_item]).to receive(:library).and_return("MUSIC")
      expect(subject.music_pickup?).to eq(true)
    end
    it "is false for not music" do
      allow(@input[:solr_item]).to receive(:library).and_return("AAEL")
      expect(subject.music_pickup?).to eq(false)
    end
  end
  context "#aael_pickup?" do
    it "is true if library is aael" do
      allow(@input[:solr_item]).to receive(:library).and_return("AAEL")
      expect(subject.aael_pickup?).to eq(true)
    end
    it "is false for not aael" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      expect(subject.aael_pickup?).to eq(false)
    end
  end
  context "#flint_pickup?" do
    it "is true if library is flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("FLINT")
      expect(subject.flint_pickup?).to eq(true)
    end
    it "is false for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      expect(subject.flint_pickup?).to eq(false)
    end
  end
  context "#flint?" do
    it "is true if library is flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("FLINT")
      expect(subject.flint?).to eq(true)
    end
    it "is false for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      expect(subject.flint?).to eq(false)
    end
  end
  context "#not_flint?" do
    it "is false if library is flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("FLINT")
      expect(subject.not_flint?).to eq(false)
    end
    it "is true for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      expect(subject.not_flint?).to eq(true)
    end
  end
  context "#ann_arbor?" do
    it "is false if library is flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("FLINT")
      expect(subject.ann_arbor?).to eq(false)
    end
    it "is true for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      expect(subject.ann_arbor?).to eq(true)
    end
  end
  context "#shapiro_pickup?" do
    it "is true if library is in shapiro list" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      expect(subject.shapiro_pickup?).to eq(true)
    end
    it "is false for not shapiro" do
      allow(@input[:solr_item]).to receive(:library).and_return("AAEL")
      expect(subject.shapiro_pickup?).to eq(false)
    end
  end
  context "#shapiro_and_aael_pickup?" do
    it "is true if library is in shapiro_and_aael_pickup list" do
      allow(@input[:solr_item]).to receive(:library).and_return("ELLS")
      expect(subject.shapiro_and_aael_pickup?).to eq(true)
    end
    it "is false for sublibraries not in shapiro_and_aael_pickup list" do
      allow(@input[:solr_item]).to receive(:library).and_return("AAEL")
      expect(subject.shapiro_and_aael_pickup?).to eq(false)
    end
  end
  context "#reopened?" do
    it "is true if sub_library is in reopened list" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      expect(subject.reopened?).to eq(true)
    end
    it "is false for not reopened" do
      allow(@input[:solr_item]).to receive(:library).and_return("ELLS")
      expect(subject.reopened?).to eq(false)
    end
  end
  context "#standard_pickup?" do
    it "is true if sub_library is flint (for now)" do
      allow(@input[:solr_item]).to receive(:library).and_return("FLINT")
      expect(subject.standard_pickup?).to eq(true)
    end
    it "is false for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      expect(subject.standard_pickup?).to eq(false)
    end
  end
  context "#not_pickup?" do
    it "is true if item is not in any of the pickup locations" do
      allow(@input[:solr_item]).to receive(:library).and_return("BSTA")
      expect(subject.not_pickup?).to eq(true)
    end
    it "is false if item is in any of the pickup locations" do
      allow(@input[:solr_item]).to receive(:library).and_return("FLINT")
      expect(subject.not_pickup?).to eq(false)
    end
  end
  context "#checked_out?" do
    it "is true if item has a due date" do
      @input[:alma_loan] = Hash.new("due_date" => "2021-10-01T03:59:00Z")
      expect(subject.checked_out?).to eq(true)
    end
    it "is false if item does not have a due date" do
      expect(subject.checked_out?).to eq(false)
    end
  end
  context "#not_checked_out?" do
    it "is true if item doesn't have due date" do
      expect(subject.not_checked_out?).to eq(true)
    end
    it "is false if item does has a due date" do
      @input[:alma_loan] = Hash.new("due_date" => "2021-10-01T03:59:00Z")
      expect(subject.not_checked_out?).to eq(false)
    end
  end
  context "building_use_only only item with item_policy 08" do
    before(:each) do
      allow(@input[:solr_item]).to receive(:item_policy).and_return("08")
    end
    it "has true #building_use_only?" do
      expect(subject.building_use_only?).to eq(true)
    end
    it "has false #not_building_use_only?" do
      expect(subject.not_building_use_only?).to eq(false)
    end
  end
  context "building_use_only only item with Fulfillment Unit Limited" do
    before(:each) do
      allow(@input[:solr_item]).to receive(:fulfillment_unit).and_return("Limited")
    end
    it "has true #building_use_only?" do
      expect(subject.building_use_only?).to eq(true)
    end
    it "has false #not_building_use_only?" do
      expect(subject.not_building_use_only?).to eq(false)
    end
  end
  context "not building_use_only item" do
    before(:each) do
      allow(@input[:solr_item]).to receive(:item_policy).and_return("01")
    end
    it "has false #building_use_only?" do
      expect(subject.building_use_only?).to eq(false)
    end
    it "has true #not_building_use_only?" do
      expect(subject.not_building_use_only?).to eq(true)
    end
  end
  context "short loan item" do
    [
      {value: "06", desc: "4-hour loan"},
      {value: "07", desc: "2-hour loan"},
      {value: "1 Day Loan", desc: "1-day loan"}
    ].each do |policy|
      context "Policy: #{policy[:desc]}" do
        before(:each) do
          allow(@input[:solr_item]).to receive(:item_policy).and_return(policy[:value])
        end
        it "has true #short_loan?" do
          expect(subject.short_loan?).to eq(true)
        end
        it "has false #not_short_loan?" do
          expect(subject.not_short_loan?).to eq(false)
        end
      end
    end
    context "Policy: Default" do
      before(:each) do
        allow(@input[:solr_item]).to receive(:item_policy).and_return(nil)
      end
      it "has false #short_loan?" do
        expect(subject.short_loan?).to eq(false)
      end
      it "has false #not_short_loan?" do
        expect(subject.not_short_loan?).to eq(true)
      end
    end
    it "is true for item policy 06" do
      allow(@input[:solr_item]).to receive(:item_policy).and_return("06")
    end
    it "is true for item policy 07" do
      allow(@input[:solr_item]).to receive(:item_policy).and_return("07")
    end
    it "is true for item policy 1 Day Loan" do
      allow(@input[:solr_item]).to receive(:item_policy).and_return("one")
    end
  end
  context "#not_pickup_or_checkout?" do
    it "is true if item is not in any of the pickup locations" do
      allow(@input[:solr_item]).to receive(:library).and_return("BSTA")
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is checked out" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      @input[:alma_loan] = Hash.new("due_date" => "2021-10-01T03:59:00Z")
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is missing" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:process_type).and_return("MISSING")
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is building_use_only" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:item_policy).and_return("08")
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is false if item is available and pickup-able" do
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:item_policy).and_return("01")
      expect(subject.not_pickup_or_checkout?).to eq(false)
    end
  end
  context "#can_request?" do
    it "is true if it would get a 'Get This' link" do
      allow(@input[:solr_item]).to receive(:library).and_return("SHAP")
      allow(@input[:solr_item]).to receive(:location).and_return("NONE")
      allow(@input[:solr_item]).to receive(:item_policy).and_return("01")
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      allow(@input[:solr_item]).to receive(:can_reserve?).and_return(false)
      allow(@input[:solr_item]).to receive(:record_has_finding_aid).and_return(false)
      expect(subject.can_request?).to eq(true)
    end
    it "is false if it wouldn't get a 'Get This' link" do
      allow(@input[:solr_item]).to receive(:library).and_return("AAEL")
      allow(@input[:solr_item]).to receive(:item_policy).and_return("05")
      allow(@input[:solr_item]).to receive(:can_reserve?).and_return(false)
      allow(@input[:solr_item]).to receive(:record_has_finding_aid).and_return(false)
      expect(subject.can_request?).to eq(false)
    end
  end
  # This is so Doc Del requests for not empty holdings have something to put in
  # CitedTitle
  context "cited_title" do
    it "is an empty string" do
      expect(subject.cited_title).to eq("")
    end
  end
  context "#missing?" do
    it "is true if item has missing process_type" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("MISSING")
      expect(subject.missing?).to eq(true)
    end
    it "is false if item does not have missing process_type" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.missing?).to eq(false)
    end
  end
  context "#not_missing?" do
    it "is true if item has missing status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("MISSING")
      expect(subject.not_missing?).to eq(false)
    end
    it "is true if item does not have missing status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.not_missing?).to eq(true)
    end
  end
  context "#in_process?" do
    it "is true if item is in some kind of process" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("SOME PROCESS")
      expect(subject.in_process?).to eq(true)
    end
    it "is false if item is not in a process" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.in_process?).to eq(false)
    end
  end
  context "#not_in_process?" do
    it "is true if item is not in some kind of process" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.not_in_process?).to eq(true)
    end
    it "is false if item is in a process" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("SOME PROCESS")
      expect(subject.not_in_process?).to eq(false)
    end
  end
  context "#in_acq?" do
    it "is true if item has on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("ACQ")
      expect(subject.in_acq?).to eq(true)
    end
    it "is false if item does not have on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.in_acq?).to eq(false)
    end
  end
  context "#not_in_acq?" do
    it "is true if item does not have on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.not_in_acq?).to eq(true)
    end
    it "is false if item has on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("ACQ")
      expect(subject.not_in_acq?).to eq(false)
    end
  end
  context "#closed_stacks?" do
    it "is true if the fulfillment_unit is 'Closed Stacks'" do
      allow(@input[:solr_item]).to receive(:location_type).and_return("OPEN")
      allow(@input[:solr_item]).to receive(:fulfillment_unit).and_return("Closed Stacks")
      allow(@input[:holding]).to receive(:display_name).and_return("DISPLAY_NAME")
      expect(subject.closed_stacks?).to eq(true)
    end
    it "is true if the location type is closed but the fulfillment unit is limited" do
      allow(@input[:solr_item]).to receive(:location_type).and_return("CLOSED")
      allow(@input[:solr_item]).to receive(:fulfillment_unit).and_return("Limited")
      allow(@input[:holding]).to receive(:display_name).and_return("DISPLAY_NAME")
      expect(subject.closed_stacks?).to eq(true)
    end
    it "is false if the location type is OPEN and the fulfillment unit is Limited" do
      allow(@input[:solr_item]).to receive(:location_type).and_return("OPEN")
      allow(@input[:solr_item]).to receive(:fulfillment_unit).and_return("Limited")
      allow(@input[:holding]).to receive(:display_name).and_return("DISPLAY_NAME")
      expect(subject.closed_stacks?).to eq(false)
    end
    it "is false if location type is nil and fulfillment unit is Limited" do
      allow(@input[:solr_item]).to receive(:location_type).and_return(nil)
      allow(@input[:solr_item]).to receive(:fulfillment_unit).and_return("Limited")
      allow(@input[:holding]).to receive(:display_name).and_return("DISPLAY_NAME")
      expect(subject.closed_stacks?).to eq(false)
    end
  end
  context "#recallable?" do
    it "is true for non reserve item,  that's on loan" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("LOAN")
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:location).and_return("GRAD")
      @input[:alma_loan] = {"process_status" => "LOAN"}
      expect(subject.recallable?).to eq(true)
    end
    it "is false for reserve item that's in process" do
      allow(@input[:solr_item]).to receive(:process_type).and_return("LOAN")
      @input[:alma_loan] = {"process_status" => "LOAN"}
      allow(@input[:solr_item]).to receive(:library).and_return("HATCH")
      allow(@input[:solr_item]).to receive(:location).and_return("RESC")
      expect(subject.recallable?).to eq(false)
    end
  end
end
