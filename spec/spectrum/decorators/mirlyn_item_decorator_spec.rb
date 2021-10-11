require_relative '../../spec_helper'

describe Spectrum::Decorators::MirlynItemDecorator do
  before(:each) do
    @mirlyn_item_double = instance_double(Spectrum::Entities::MirlynItem) 
    @hathi_item_double = instance_double(Spectrum::Entities::HathiItem, id: '1234')
    @hathi_holding_double = instance_double(Spectrum::Entities::HathiHolding)
  end
  subject do
    described_class.new(@mirlyn_item_double, [@hathi_holding_double])
  end
  context "#etas?" do
    it "is true if Hathi item contains etas status" do
      allow(@hathi_item_double).to receive(:status).and_return("Full text available, simultaneous access is limited (HathiTrust log in required)")
      allow(@hathi_holding_double).to receive(:items).and_return([@hathi_item_double])
      expect(subject.etas?).to eq(true)
    end
    it "is false if any of the items are not with etas status" do
      allow(@hathi_item_double).to receive(:status).and_return("Full text")
      allow(@hathi_holding_double).to receive(:items).and_return([@hathi_item_double])
      expect(subject.etas?).to eq(false)
    end
  end
  context "#not_etas?" do
    it "is false if Hathi item contains etas status" do
      allow(@hathi_item_double).to receive(:status).and_return("Full text available, simultaneous access is limited (HathiTrust log in required)")
      allow(@hathi_holding_double).to receive(:items).and_return([@hathi_item_double])
      expect(subject.not_etas?).to eq(false)
    end
    it "is true if any of the items are not with etas status" do
      allow(@hathi_item_double).to receive(:status).and_return("Full text")
      allow(@hathi_holding_double).to receive(:items).and_return([@hathi_item_double])
      expect(subject.not_etas?).to eq(true)
    end
  end
  context "#music_pickup?" do
    it "is true if sub library is music" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('MUSIC')
      expect(subject.music_pickup?).to eq(true)
    end
    it "is false for not music" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('AAEL')
      expect(subject.music_pickup?).to eq(false)
    end
  end
  context "#aael_pickup?" do
    it "is true if sub library is aael" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('AAEL')
      expect(subject.aael_pickup?).to eq(true)
    end
    it "is false for not aael" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      expect(subject.aael_pickup?).to eq(false)
    end
  end
  context "#flint_pickup?" do
    it "is true if sub_library is flint" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('FLINT')
      expect(subject.flint_pickup?).to eq(true)
    end
    it "is false for not flint" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      expect(subject.flint_pickup?).to eq(false)
    end
  end
  context "#flint?" do
    it "is true if sub_library is flint" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('FLINT')
      expect(subject.flint?).to eq(true)
    end
    it "is false for not flint" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      expect(subject.flint?).to eq(false)
    end
  end
  context "#shapiro_pickup?" do
    it "is true if sub_library is in shapiro list" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('SHAP')
      expect(subject.shapiro_pickup?).to eq(true)
    end
    it "is false for not shapiro" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('AAEL')
      expect(subject.shapiro_pickup?).to eq(false)
    end
  end
  context "#shapiro_and_aael_pickup?" do
    it "is true if sub_library is in shapiro_and_aael_pickup list" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('ELLS')
      expect(subject.shapiro_and_aael_pickup?).to eq(true)
    end
    it "is false for sublibraries not in shapiro_and_aael_pickup list" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('AAEL')
      expect(subject.shapiro_and_aael_pickup?).to eq(false)
    end
  end
  context "#reopened?" do
    it "is true if sub_library is in reopened list" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('SHAP')
      expect(subject.reopened?).to eq(true)
    end
    it "is false for not reopened" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('ELLS')
      expect(subject.reopened?).to eq(false)
    end
  end
  context "#standard_pickup?" do
    it "is true if sub_library is flint (for now)" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('FLINT')
      expect(subject.standard_pickup?).to eq(true)
    end
    it "is false for not flint" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      expect(subject.standard_pickup?).to eq(false)
    end
  end
  context "#can_request?" do
    it "is true if mirlyn item has can_request?" do
      allow(@mirlyn_item_double).to receive("can_request?").and_return(true)
      expect(subject.can_request?).to eq(true)
    end
    it "is true if item.can_request? is false and item is in HSRS" do
      allow(@mirlyn_item_double).to receive("can_request?").and_return(false)
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HSRS')
      expect(subject.can_request?).to eq(true)
    end
    it "is true if item.can_request? is false and item is in HERB" do
      allow(@mirlyn_item_double).to receive("can_request?").and_return(false)
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HERB')
      expect(subject.can_request?).to eq(true)
    end
    it "is true if item.can_request? is false and item is in MUSM" do
      allow(@mirlyn_item_double).to receive("can_request?").and_return(false)
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('MUSM')
      expect(subject.can_request?).to eq(true)
    end
    it "is false if item not in HSRS, HERB, MUSM and item.can_request? false" do
      allow(@mirlyn_item_double).to receive("can_request?").and_return(false)
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      expect(subject.can_request?).to eq(false)
    end
  end
  context "#checked_out?" do
    it "is true if status has 'Checked out'" do
      allow(@mirlyn_item_double).to receive(:status).and_return('Checked out')
      expect(subject.checked_out?).to eq(true)
    end
    it "is true if status has 'Recalled'" do
      allow(@mirlyn_item_double).to receive(:status).and_return('Recalled')
      expect(subject.checked_out?).to eq(true)
    end
    it "is true if status has 'Requested'" do
      allow(@mirlyn_item_double).to receive(:status).and_return('Requested')
      expect(subject.checked_out?).to eq(true)
    end
    it "is true if status has 'Extended loan'" do
      allow(@mirlyn_item_double).to receive(:status).and_return('Extended loan')
      expect(subject.checked_out?).to eq(true)
    end
    it "is false if not any of the above" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On shelf')
      expect(subject.checked_out?).to eq(false)
    end
  end
  context "#not_checked_out?" do
    it "is true if item doesn't have a checked out status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On shelf')
      expect(subject.not_checked_out?).to eq(true)
    end
    it "is false if item does have a checked out status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('Checked out')
      expect(subject.not_checked_out?).to eq(false)
    end
  end
  context "#not_flint?" do
    it "is false if sub_library is flint" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('FLINT')
      expect(subject.not_flint?).to eq(false)
    end
    it "is true for not flint" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      expect(subject.not_flint?).to eq(true)
    end
  end
  context "#missing?" do
    it "is true if item has missing status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('missing')
      expect(subject.missing?).to eq(true)
    end
    it "is false if item does not have missing status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On Order')
      expect(subject.missing?).to eq(false)
    end
  end
  context "#not_missing?" do
    it "is true if item has missing status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('missing')
      expect(subject.not_missing?).to eq(false)
    end
    it "is true if item does not have missing status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On Order')
      expect(subject.not_missing?).to eq(true)
    end
  end
  context "#on_order?" do
    it "is true if item has on order status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On Order')
      expect(subject.on_order?).to eq(true)
    end
    it "is false if item does not have on order status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On shelf')
      expect(subject.on_order?).to eq(false)
    end
  end
  context "#not_on_order?" do
    it "is true if item does not have on order status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On shelf')
      expect(subject.not_on_order?).to eq(true)
    end
    it "is false if item has on order status" do
      allow(@mirlyn_item_double).to receive(:status).and_return('On Order')
      expect(subject.not_on_order?).to eq(false)
    end
  end
  context "#not_pickup?" do
    it "is true if item is not in any of the pickup locations" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('BSTA')
      expect(subject.not_pickup?).to eq(true)
    end
    it "is false if item is in any of the pickup locations" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('FLINT')
      expect(subject.not_pickup?).to eq(false)
    end
  end
  context "#not_pickup_or_checkout?" do
    it "is true if item is not in any of the pickup locations" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('BSTA')
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is checked out" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      allow(@mirlyn_item_double).to receive(:status).and_return('Checked out')
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is missing" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      allow(@mirlyn_item_double).to receive(:status).and_return('missing')
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is true if item is building_use_only" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      allow(@mirlyn_item_double).to receive(:status).and_return('Building use only')
      expect(subject.not_pickup_or_checkout?).to eq(true)
    end
    it "is false if item is available and pickup-able" do
      allow(@mirlyn_item_double).to receive(:sub_library).and_return('HATCH')
      allow(@mirlyn_item_double).to receive(:status).and_return('On shelf')
      expect(subject.not_pickup_or_checkout?).to eq(false)
    end
  end
  context ".for" do
    before(:each) do
      @source = nil 
      @request = instance_double(Spectrum::Request::GetThis, id: '123456') 
      @holdings_double = instance_double(Spectrum::Entities::Holdings)
    end
    let(:gh_factory) { lambda{|s,r| @holdings_double } }
    subject do
      described_class.for(@source, @request, gh_factory)
    end
    it "returns a AvailableOnlineHolding for valid available-online barcode" do
      allow(@request).to receive(:barcode).and_return('available-online')
      expect(subject.class.name.to_s).to eq('Spectrum::AvailableOnlineHolding')
    end
    it "returns a MirlynItemDecorator for valid barcode" do
      allow(@request).to receive(:barcode).and_return('3312345')
      allow(@holdings_double).to receive(:find_item).and_return({})
      allow(@holdings_double).to receive(:hathi_holdings).and_return([])
      expect(subject.class.name.to_s).to eq('Spectrum::Decorators::MirlynItemDecorator')
    end
    
  end
end
