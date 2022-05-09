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
    it "matches AAEL 05" do
      allow(@item).to receive(:library).and_return('AAEL')
      allow(@item).to receive(:item_policy).and_return('05')
      expect(subject).to eq(true)
    end
    it "matches FLINT 10" do
      allow(@item).to receive(:library).and_return('FLINT')
      allow(@item).to receive(:item_policy).and_return('10')
      expect(subject).to eq(true)
    end
  end
end
