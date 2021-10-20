require_relative '../../rails_helper'

describe Spectrum::Holding::NoAction do
  before(:each) do
    @item = instance_double(Spectrum::Entities::AlmaItem, library: 'HATCH', location: 'NONE', item_policy: '01', process_type: nil, barcode: 'somebarcode')
  end
  subject do
    described_class.match?(@item)
  end
  context "::match?" do
    it "generally does not match" do
      expect(subject).to eq(false)
    end
    it "matches Item Policy 06" do
      allow(@item).to receive(:item_policy).and_return('06')
      expect(subject).to eq(true)
    end
    it "matches Item Policy 07" do
      allow(@item).to receive(:item_policy).and_return('07')
      expect(subject).to eq(true)
    end
    it "matches AAEL 05" do
      allow(@item).to receive(:library).and_return('AAEL')
      allow(@item).to receive(:item_policy).and_return('05')
      expect(subject).to eq(true)
    end
    it "matches FINE 03" do
      allow(@item).to receive(:library).and_return('FINE')
      allow(@item).to receive(:item_policy).and_return('03')
      expect(subject).to eq(true)
    end
    it "matches FINE 05" do
      allow(@item).to receive(:library).and_return('FINE')
      allow(@item).to receive(:item_policy).and_return('05')
      expect(subject).to eq(true)
    end
    it "matches FLINT 05" do
      allow(@item).to receive(:library).and_return('FLINT')
      allow(@item).to receive(:item_policy).and_return('05')
      expect(subject).to eq(true)
    end
    it "matches FLINT 10" do
      allow(@item).to receive(:library).and_return('FLINT')
      allow(@item).to receive(:item_policy).and_return('10')
      expect(subject).to eq(true)
    end
    it "matches MUSM 03" do
      allow(@item).to receive(:library).and_return('MUSM')
      allow(@item).to receive(:item_policy).and_return('03')
      expect(subject).to eq(true)
    end
    it "matches HATCH PAPY" do
      allow(@item).to receive(:location).and_return('PAPY')
      expect(subject).to eq(true)
    end
    it "matches BTSA 08" do
      allow(@item).to receive(:library).and_return('BTSA')
      allow(@item).to receive(:item_policy).and_return('08')
      expect(subject).to eq(true)
    end
    it "matches CSCAR 08" do
      allow(@item).to receive(:library).and_return('CSCAR')
      allow(@item).to receive(:item_policy).and_return('08')
      expect(subject).to eq(true)
    end
    it "matches DHCL BOOK 08" do
      allow(@item).to receive(:library).and_return('DHCL')
      allow(@item).to receive(:location).and_return('BOOK')
      allow(@item).to receive(:item_policy).and_return('08')
      expect(subject).to eq(true)
    end
    it "matches DHCL OVR 08" do
      allow(@item).to receive(:library).and_return('DHCL')
      allow(@item).to receive(:location).and_return('OVR')
      allow(@item).to receive(:item_policy).and_return('08')
      expect(subject).to eq(true)
    end
  end
end
