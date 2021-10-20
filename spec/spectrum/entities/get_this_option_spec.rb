require_relative '../../rails_helper'
describe Spectrum::Entities::GetThisOption do
  before(:each) do
     @patron = instance_double(Spectrum::Entities::AlmaUser)
     @item = double('Spectrum::Decorators::PhysicalItemDecorator')
     Spectrum::Entities::GetThisOptions.configure('spec/fixtures/new_get_this_policy.yml')
     Spectrum::Entities::LocationLabels.configure('spec/fixtures/location_labels.yml')

  end
  context "No form" do
    subject do
      hold = Spectrum::Entities::GetThisOptions.all[3]
      described_class.for(option: hold, patron: @patron, item: @item)
    end
    it "returns a GetThisOption"  do
      expect(subject.class.to_s).to eq('Spectrum::Entities::GetThisOption')
    end
    it "has a proper looking form" do
      expect(subject.form).to eq(JSON.parse(File.read('./spec/fixtures/get_this/no_form.json')))
    end
  end
  context "Link" do
    subject do
      hold = Spectrum::Entities::GetThisOptions.all[0]
      described_class.for(option: hold, patron: @patron, item: @item)
    end
    it "returns a GetThisOption::Link"  do
      expect(subject.class.to_s).to eq('Spectrum::Entities::GetThisOption::Link')
    end
    it "has a proper looking form" do
      expect(subject.form).to eq(JSON.parse(File.read('./spec/fixtures/get_this/link.json')))
    end
  end
  context "Alma Hold" do
    subject do 
      hold = Spectrum::Entities::GetThisOptions.all[1]
      described_class.for(option: hold, patron: @patron, item: @item)
    end
    it "returns an alma hold" do
      expect(subject.class.to_s).to include('AlmaHold')
    end
    it "has a proper looking form" do
      allow(@item).to receive(:mms_id).and_return('MMS_ID')
      allow(@item).to receive(:holding_id).and_return('HOLDING_ID')
      allow(@item).to receive(:item_id).and_return('ITEM_ID')
      expect(subject.form('DATE')).to eq(JSON.parse(File.read('./spec/fixtures/get_this/alma_hold.json')))
    end
  end
  context "ILLiad Hold" do
    subject do
      hold = Spectrum::Entities::GetThisOptions.all[2]
      described_class.for(option: hold, 
        patron: @patron, item: @item)
    end
    it "returns an ILLiadRequest" do
      expect(subject.class.to_s).to include('ILLiadRequest')
    end
    it "has a proper looking form" do
      allow(@item).to receive(:accession_number).and_return('ACCESSION NUMBER')
      allow(@item).to receive(:isbn).and_return('ISBN')
      allow(@item).to receive(:title).and_return('TITLE')
      allow(@item).to receive(:author).and_return('AUTHOR')
      allow(@item).to receive(:date).and_return('DATE')
      allow(@item).to receive(:pub).and_return('PUB')
      allow(@item).to receive(:place).and_return('PLACE')
      allow(@item).to receive(:callnumber).and_return('CALLNUMBER')
      allow(@item).to receive(:edition).and_return('EDITION')
      allow(@item).to receive(:library_display_name).and_return('LOCATION')
      allow(@item).to receive(:barcode).and_return('BARCODE')
      expect(subject.form).to eq(JSON.parse(File.read('./spec/fixtures/get_this/illiad_request.json')))
    end
    
  end
end

