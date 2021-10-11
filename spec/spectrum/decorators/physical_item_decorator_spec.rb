require_relative '../../rails_helper'

describe Spectrum::Decorators::PhysicalItemDecorator do
  before(:each) do
    @input = {
      holding:  instance_double(Spectrum::Entities::AlmaHolding),
      alma_loan: nil,
      solr_item:  double('BibRecord::AlmaItem', process_type: nil, item_policy: '01', barcode: 'somebarcode'),
      bib_record: instance_double(Spectrum::BibRecord)
    }
  end
  subject do
    item = Spectrum::Entities::AlmaItem.new(**@input)
    described_class.new(item)
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
      allow(@input[:solr_item]).to receive(:library).and_return('MUSIC')
      expect(subject.music_pickup?).to eq(true)
    end
    it "is false for not music" do
      allow(@input[:solr_item]).to receive(:library).and_return('AAEL')
      expect(subject.music_pickup?).to eq(false)
    end
  end
  context "#aael_pickup?" do
    it "is true if library is aael" do
      allow(@input[:solr_item]).to receive(:library).and_return('AAEL')
      expect(subject.aael_pickup?).to eq(true)
    end
    it "is false for not aael" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      expect(subject.aael_pickup?).to eq(false)
    end
  end
  context "#flint_pickup?" do
    it "is true if library is flint" do
      allow(@input[:solr_item]).to receive(:library).and_return('FLINT')
      expect(subject.flint_pickup?).to eq(true)
    end
    it "is false for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      expect(subject.flint_pickup?).to eq(false)
    end
  end
  context "#flint?" do
    it "is true if library is flint" do
      allow(@input[:solr_item]).to receive(:library).and_return('FLINT')
      expect(subject.flint?).to eq(true)
    end
    it "is false for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      expect(subject.flint?).to eq(false)
    end
  end
  context "#not_flint?" do
    it "is false if library is flint" do
      allow(@input[:solr_item]).to receive(:library).and_return('FLINT')
      expect(subject.not_flint?).to eq(false)
    end
    it "is true for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      expect(subject.not_flint?).to eq(true)
    end
  end
  context "#shapiro_pickup?" do
    it "is true if library is in shapiro list" do
      allow(@input[:solr_item]).to receive(:library).and_return('SHAP')
      expect(subject.shapiro_pickup?).to eq(true)
    end
    it "is false for not shapiro" do
      allow(@input[:solr_item]).to receive(:library).and_return('AAEL')
      expect(subject.shapiro_pickup?).to eq(false)
    end
  end
  context "#shapiro_and_aael_pickup?" do
    it "is true if library is in shapiro_and_aael_pickup list" do
      allow(@input[:solr_item]).to receive(:library).and_return('ELLS')
      expect(subject.shapiro_and_aael_pickup?).to eq(true)
    end
    it "is false for sublibraries not in shapiro_and_aael_pickup list" do
      allow(@input[:solr_item]).to receive(:library).and_return('AAEL')
      expect(subject.shapiro_and_aael_pickup?).to eq(false)
    end
  end
  context "#reopened?" do
    it "is true if sub_library is in reopened list" do
      allow(@input[:solr_item]).to receive(:library).and_return('SHAP')
      expect(subject.reopened?).to eq(true)
    end
    it "is false for not reopened" do
      allow(@input[:solr_item]).to receive(:library).and_return('ELLS')
      expect(subject.reopened?).to eq(false)
    end
  end
  context "#standard_pickup?" do
    it "is true if sub_library is flint (for now)" do
      allow(@input[:solr_item]).to receive(:library).and_return('FLINT')
      expect(subject.standard_pickup?).to eq(true)
    end
    it "is false for not flint" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      expect(subject.standard_pickup?).to eq(false)
    end
  end
  context "#not_pickup?" do
    it "is true if item is not in any of the pickup locations" do
      allow(@input[:solr_item]).to receive(:library).and_return('BSTA')
      expect(subject.not_pickup?).to eq(true)
    end
    it "is false if item is in any of the pickup locations" do
      allow(@input[:solr_item]).to receive(:library).and_return('FLINT')
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
  context "building_use_only only item" do
    before(:each) do
      allow(@input[:solr_item]).to receive(:item_policy).and_return('08')
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
      allow(@input[:solr_item]).to receive(:item_policy).and_return('01')
    end
    it "has false #building_use_only?" do
      expect(subject.building_use_only?).to eq(false)
    end
    it "has true #not_building_use_only?" do
      expect(subject.not_building_use_only?).to eq(true)
    end
  end
  context "#not_pickup_or_checkout?" do
    it "is true if item is not in any of the pickup locations" do
      allow(@input[:solr_item]).to receive(:library).and_return('BSTA')
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is checked out" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      @input[:alma_loan] = Hash.new("due_date" => "2021-10-01T03:59:00Z")
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is missing" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      allow(@input[:solr_item]).to receive(:process_type).and_return('MISSING')
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is building_use_only" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      allow(@input[:solr_item]).to receive(:item_policy).and_return('08')
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is false if item is available and pickup-able" do
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      allow(@input[:solr_item]).to receive(:item_policy).and_return('01')
      expect(subject.not_pickup_or_checkout?).to eq(false)
    end
  end
  context "#can_request?" do
    it "is true if it would get a 'Get This' link" do
      allow(@input[:solr_item]).to receive(:library).and_return('SHAP')
      allow(@input[:solr_item]).to receive(:item_policy).and_return('01')
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      allow(@input[:solr_item]).to receive(:can_reserve?).and_return(false)
      allow(@input[:solr_item]).to receive(:record_has_finding_aid).and_return(false)
      expect(subject.can_request?).to eq(true)
    end
    it "is false if it wouldn't get a 'Get This' link" do
      allow(@input[:solr_item]).to receive(:library).and_return('SHAP')
      allow(@input[:solr_item]).to receive(:item_policy).and_return('06')
      allow(@input[:solr_item]).to receive(:can_reserve?).and_return(false)
      allow(@input[:solr_item]).to receive(:record_has_finding_aid).and_return(false)
      expect(subject.can_request?).to eq(false)
    end
  end
  context "#missing?" do
    it "is true if item has missing process_type" do
      allow(@input[:solr_item]).to receive(:process_type).and_return('MISSING')
      expect(subject.missing?).to eq(true)
    end
    it "is false if item does not have missing process_type" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.missing?).to eq(false)
    end
  end
  context "#not_missing?" do
    it "is true if item has missing status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return('MISSING')
      expect(subject.not_missing?).to eq(false)
    end
    it "is true if item does not have missing status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.not_missing?).to eq(true)
    end
  end
  context "#on_order?" do
    it "is true if item has on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return('ACQ')
      expect(subject.on_order?).to eq(true)
    end
    it "is false if item does not have on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.on_order?).to eq(false)
    end
  end
  context "#not_on_order?" do
    it "is true if item does not have on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return(nil)
      expect(subject.not_on_order?).to eq(true)
    end
    it "is false if item has on order status" do
      allow(@input[:solr_item]).to receive(:process_type).and_return('ACQ')
      expect(subject.not_on_order?).to eq(false)
    end
  end
  context "#recallable?" do
    it "is true for non reserve item,  that's on loan" do
      allow(@input[:solr_item]).to receive(:process_type).and_return('LOAN')
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      allow(@input[:solr_item]).to receive(:location).and_return('GRAD')
      @input[:alma_loan] = 'not_nil'
      expect(subject.recallable?).to eq(true)
    end
  end
  it "is false for reserve item that's in process" do
      allow(@input[:solr_item]).to receive(:process_type).and_return('LOAN')
      @input[:alma_loan] = 'not_nil'
      allow(@input[:solr_item]).to receive(:library).and_return('HATCH')
      allow(@input[:solr_item]).to receive(:location).and_return('RESC')
      expect(subject.recallable?).to eq(false)
  end
end
