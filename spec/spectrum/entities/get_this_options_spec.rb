require_relative '../../spec_helper'
describe Spectrum::Entities::GetThisOptions do
 context '::options' do
   before(:each) do
     Spectrum::Entities::GetThisOptions.configure('spec/fixtures/get_this_policy.yml')
     user_methods = [ "empty?", "expired?", "active?", "can_ill?", 
                      "ann_arbor?", "flint?", "can_other?", "dearborn?"]
     @account = instance_double(Spectrum::Entities::AlmaUser)
     user_methods.each{  |method| allow(@account).to receive(method) }
      
     @bib = instance_double(Spectrum::BibRecord,
        "etas?" => false,
        "not_etas?" => false,
        "can_scan?" => false
     )
     @item = double('Spectrum::Decorators::Physical_Item_Decorator')
     ["can_request?", "not_etas?", "not_pickup_or_checkout?", "checked_out?", 
      "not_pickup?", "not_flint?", "etas?", "reopened?", "not_checked_out?", 
      "not_missing?", "not_on_order?", "on_order?", "flint?", "standard_pickup?", 
      "shapiro_and_aael_pickup?", "flint_pickup?", "shapiro_pickup?", 
      "aael_pickup?", "music_pickup?"].each do |method|
       allow(@item).to receive(method)
     end
   end
   subject do
     described_class.for(@account, @bib, @item)
   end
   it "returns weblogin" do
      allow(@account).to receive(:empty?).and_return(true)
      allow(@item).to receive(:can_request?).and_return(true)
      expect(subject.count).to eq(1)
      expect(subject.first["service_type"]).to eq("Weblogin")
   end
 end
 context '::all' do
   it "returns the full array" do
     expect(described_class.all.count).to eq(27)
   end
 end
end
