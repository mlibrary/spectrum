require_relative '../../rails_helper'
describe Spectrum::Holding::PhysicalItemStatus do
  before(:each) do
    @solr_item = double("Spectrum::BibRecord:AlmaHolding::Item", process_type: nil, location: 'GRAD', library: 'HATCH', temp_location?: false, item_location_text: 'Hatcher Graduate Library', can_reserve?: false, fulfillment_unit: "General", item_policy: nil)
    @bib_record = instance_double(Spectrum::BibRecord)
    @alma_item = Spectrum::Entities::AlmaItem.new(solr_item: @solr_item, holding: double("AlmaHolding"), alma_loan: nil, bib_record: @bib_record)
  end
  subject do
    described_class.for(@alma_item) 
  end
  context "Not loaned out; no process" do
    context "Policy: Loan 1" do
      before(:each) do
        allow(@alma_item).to receive(:item_policy).and_return('01')
      end
      it "returns success status non-temporarily-moved-item item" do
#        allow(@alma_item).to receive(:requested?).and_return(false)
        expect(subject.to_h).to eq({text: 'On shelf', intent: 'success', icon: 'check_circle'})
        expect(subject.class.to_s).to include('Success')
      end
      it "returns success for reserves item" do
        allow(@alma_item).to receive(:in_reserves?).and_return(true)
        expect(subject.to_h).to eq({text: 'On reserve at Hatcher Graduate Library', intent: 'success', icon: 'check_circle'})
      end
      it "returns success for temporaryily located item" do
        allow(@alma_item).to receive(:in_reserves?).and_return(false)
        allow(@solr_item).to receive(:temp_location?).and_return(true)
        expect(subject.to_h).to eq({text: 'Temporary location: Hatcher Graduate Library', intent: 'success', icon: 'check_circle'})
      end
      it "returns error for item in an unavailable temporary location" do
        allow(@solr_item).to receive(:temp_location?).and_return(true)
        allow(@alma_item).to receive(:in_unavailable_temporary_location?).and_return(true)
        expect(subject.to_h).to eq({text: 'Unavailable', intent: 'error', icon: 'error'})
        expect(subject.class.to_s).to include('Error')
      end
      #it "returns error for requested item" do
        #allow(@alma_item).to receive(:requested?).and_return(true)
        #expect(subject.to_h).to eq({text: 'Requested', intent: 'error', icon: 'error'})
        #expect(subject.class.to_s).to include('Error')
      #end
    end
    context "Bentley, Clements, or Special Collections" do
      it "always shows Reading Room Use Only" do
        allow(@alma_item).to receive(:can_reserve?).and_return(true)
        expect(subject.class.to_s).to include('Success')
        expect(subject.text).to eq('Reading Room use only')
      end
    end
    context "Fulfillment Unit: Limited" do
      before(:each) do
        allow(@alma_item).to receive(:fulfillment_unit).and_return('Limited')
      end
      it "handles building_use_only" do
        allow(@alma_item).to receive(:library).and_return('MUSIC')
        expect(subject.class.to_s).to include('Success')
        expect(subject.text).to eq('Building use only')
      end
      it "handles temporary location" do
        allow(@alma_item).to receive(:in_reserves?).and_return(false)
        allow(@solr_item).to receive(:temp_location?).and_return(true)
        expect(subject.text).to eq('Temporary location: Hatcher Graduate Library; Building use only')
      end
    end
    context "Policy: Loan 08" do
      before(:each) do
        allow(@alma_item).to receive(:item_policy).and_return('08')
      end
      it "handles building_use_only" do
        allow(@alma_item).to receive(:library).and_return('MUSIC')
        expect(subject.class.to_s).to include('Success')
        expect(subject.text).to eq('Building use only')
      end
      it "handles temporary location" do
        allow(@alma_item).to receive(:in_reserves?).and_return(false)
        allow(@solr_item).to receive(:temp_location?).and_return(true)
        expect(subject.text).to eq('Temporary location: Hatcher Graduate Library; Building use only')
      end
    end
    hour_loans = [
        {value: "06", desc: '4-hour loan'},
        {value: "07", desc: '2-hour loan'},
        {value: "1 Day Loan", desc: '1-day loan'},
    ]
    hour_loans.each do |policy|
      context "Policy: #{policy[:desc]}" do
        it "returns On Shelf and length of time" do
          allow(@alma_item).to receive(:item_policy).and_return(policy[:value])
          expect(subject.class.to_s).to include('Success')
          expect(subject.text).to eq("On shelf (#{policy[:desc]})")
        end
        
      end

    end
    context "on Loan" do
      before(:each) do 
        allow(@alma_item).to receive(:process_type).and_return('LOAN')
        allow(@alma_item).to receive(:due_date).and_return('2021-10-01T08:30:00Z')
        allow(@alma_item).to receive(:item_policy).and_return('01')
      end
      it "handles nil due_date" do
        allow(@alma_item).to receive(:due_date).and_return(nil)
        expect(subject.class.to_s).to include('Warning')
        expect(subject.text).to eq("Checked out")
      end
      it "handles 01 item_policy" do
        expect(subject.class.to_s).to include('Warning')
        expect(subject.text).to eq("Checked out: due Oct 01, 2021")
      end
      it "handles on reserve" do
        allow(@alma_item).to receive(:item_location_text).and_return('Hatcher Graduate Library')
        allow(@alma_item).to receive(:in_reserves?).and_return(true)
        expect(subject.text).to eq("Checked out: due Oct 01, 2021 On reserve at Hatcher Graduate Library")
      end

      hour_loans[0..1].each do |policy|
        it "returns Checked out with length of time for policy #{policy[:desc]}" do
          allow(@alma_item).to receive(:item_policy).and_return(policy[:value])
          expect(subject.class.to_s).to include('Warning')
          expect(subject.text).to eq("Checked out: due Oct 01, 2021 at 8:30 AM")
        end
      end
      
    end
  end
end

