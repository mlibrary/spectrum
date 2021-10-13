require_relative '../../rails_helper'
describe Spectrum::Entities::NewHathiHolding do
  let(:mms_id) {'990020578280206381'}
  let(:etas_status) {"Full text available, simultaneous access is limited (HathiTrust log in required)"}
  before(:each) do
    @solr_bib_alma = JSON.parse(File.read('./spec/fixtures/solr_bib_alma.json'))
  end
  subject do
    described_class.new(Spectrum::BibRecord.new(@solr_bib_alma))
  end
  ['callnumber', 'sub_library', 'collection'].each do |method|
    context "#{method}" do
      it "has an empty #{method}" do
        expect(subject.public_send(method)).to eq('')
      end
    end
  end
  context "#empty?" do
    it "says if it's not" do
      expect(subject.empty?).to eq(false)
    end
    it "says if it is empty"  do
      holdings = JSON.parse(@solr_bib_alma["response"]["docs"][0]["hol"])
      holdings.delete_at(1)
      @solr_bib_alma["response"]["docs"][0]["hol"] = holdings.to_json
      expect(subject.empty?).to eq(true)
    end
  end
  it "has a nil info_link" do
    expect(subject.info_link).to be_nil
  end
  it "has a doc_id" do
    expect(subject.doc_id).to eq(mms_id)

  end
  it "has a location" do
    expect(subject.location).to eq("HathiTrust Digital Library")
  end
  it "has items" do
    expect(subject.items.class.name.to_s).to  eq('Array')
  end
  let(:add_hathi_item) do
    holdings = @solr_bib_alma["response"]["docs"][0]["hol"]
    parsed_hol = JSON.parse(holdings)
    parsed_hol[1]["items"].push({})
    @solr_bib_alma["response"]["docs"][0]["hol"] = parsed_hol.to_json
  end
  context "#id" do
    
    it "has an id of first item if there is only one item" do
      expect(subject.id).to eq('mdp.39015017893416')
    end
    it "returns nil if there are multiple items" do
      add_hathi_item
      expect(subject.id).to be_nil
    end
  end
  context "#status" do
    it "gets status of first item if there's only one item" do
      expect(subject.status).to eq(etas_status)
    end
    it "returns nil if there are multiple items" do
      add_hathi_item
      expect(subject.status).to be_nil
    end

  end
  context ".for" do
    let(:solr_url) { 'http://localhost/solr/biblio' }
    before(:each) do
      @solr_req = stub_request(:get, "#{solr_url}/select?q=id:#{mms_id}&wt=json").to_return(body: @solr_bib_alma.to_json, status: 200, headers: {content_type: 'application/json'})
    end
    it "returns a NewHathiHolding" do
      expect(described_class.for(mms_id,solr_url).class.name.to_s).to eq(described_class.name.to_s)
      expect(@solr_req).to have_been_requested

    end
  end
end
describe Spectrum::Entities::NewHathiItem do
  before(:each) do
    @solr_bib_alma = JSON.parse(File.read('./spec/fixtures/solr_bib_alma.json'))
  end
  subject do
    bib_record = Spectrum::BibRecord.new(@solr_bib_alma)
    Spectrum::Entities::NewHathiHolding.new(bib_record).items.first
  end
  it "has a description" do
    expect(subject.description).to eq('')
  end
  it "has a source" do
    expect(subject.source).to eq('University of Michigan')
  end
  it "has rights" do
    expect(subject.rights).to eq('ic')
  end
  it "has a record" do
    expect(subject.record).to eq('990020578280206381')
  end
  it "has an id" do
    expect(subject.id).to eq('mdp.39015017893416')
  end
  context "#status" do
    it "generates appropriate status"
  end
  context "#url" do
    it "has login link" do
      expect(subject.url).to eq('http://hdl.handle.net/2027/mdp.39015017893416?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth')
    end
    it "does not have login link"  do
      holdings = JSON.parse(@solr_bib_alma["response"]["docs"][0]["hol"])
      holdings[1]["items"][0]["status"] = "Full text"
      @solr_bib_alma["response"]["docs"][0]["hol"] = holdings.to_json
      expect(subject.url).to eq('http://hdl.handle.net/2027/mdp.39015017893416')
    end

  end
end
