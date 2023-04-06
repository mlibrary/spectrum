require_relative "../../rails_helper"
class GetThisPolicyDouble
  attr_reader :account, :bib, :item
  def initialize(account, bib, item)
    @account = account
    @bib = bib
    @item = item
  end

  def resolve
    self
  end
end

describe Spectrum::Response::GetThis do
  describe "renderable" do
    before(:each) do
      stub_alma_get_request(url: "bibs/990020578280106381/loans", output: {total_record_count: 0}.to_json, query: {limit: 100, offset: 0})
      @init = {
        source: double("HoldingsSource", holdings: "http://localhost", url: "mirlyn_solr_url"),
        request: instance_double(Spectrum::Request::GetThis, id: "123456789", barcode: "39015017893416", logged_in?: true, username: "username"),

        get_this_policy_factory: lambda { |patron, bib_record, holdings_record| GetThisPolicyDouble.new(patron, bib_record, holdings_record) },
        user: instance_double(Spectrum::Entities::AlmaUser, empty?: false, expired?: false),
        bib_record: Spectrum::BibRecord.new(JSON.parse(File.read("./spec/fixtures/solr_bib_alma.json")))
      }
    end

    subject do
      described_class.new(**@init)
    end

    it "returns {} if source.holdings is empty" do
      allow(@init[:source]).to receive(:holdings).and_return(nil)
      expect(subject.renderable).to eq({})
    end
    it "returns needs_authentication if not logged in" do
      allow(@init[:request]).to receive(:logged_in?).and_return(false)
      expect(subject.renderable).to eq({status: "Not logged in", options: []})
    end

    it "returns patron_expired if patron is expired" do
      allow(@init[:user]).to receive(:expired?).and_return(true)
      expect(subject.renderable).to eq({status: "Your library account has expired. Please contact circservices@umich.edu for assistance.", options: []})
    end

    it "returns patron_not_found if error raised" do
      allow(@init[:user]).to receive(:empty?).and_return(true)

      expect(subject.renderable).to eq({status: "Patron not found", options: []})
    end

    it "calls get_this_policy with bib_record" do
      expect(subject.renderable[:options].bib.class.to_s).to eq("Spectrum::BibRecord")
    end
    it "handles an item with barcode \"available-online\"" do
      allow(@init[:request]).to receive(:barcode).and_return("available-online")
      expect(subject.renderable[:options].item.class.to_s).to include("AvailableOnlineHolding")
    end
    it "handles an item with barcode \"unavailable\"" do
      allow(@init[:request]).to receive(:barcode).and_return("unavailable")
      expect(subject.renderable[:options].item.class.to_s).to include("EmptyItemHolding")
    end

    it "calls get_this_policy with Spectrum::Decorators::PhysicalItemDecorator" do
      expect(subject.renderable[:options].item.class.to_s).to include("PhysicalItemDecorator")
    end
  end
end
