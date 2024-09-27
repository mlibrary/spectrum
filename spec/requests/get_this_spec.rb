require "spec_helper"

RSpec.describe "Profile routes", type: :request do
  include Rack::Test::Methods
  let(:app) { Spectrum::Json::App }
  let(:log_in) do
    OmniAuth.config.add_mock(:openid_connect, {info: {nickname: "tutor"}})
    OmniAuth.config.before_callback_phase do |env|
      env["omniauth.origin"] = "/login"
    end
    alma_user = JSON.parse(File.read("./spec/fixtures/alma_user.json"))
    alma_user["expiry_date"] = Date.tomorrow.strftime("%Y-%m-%dZ")
    stub_alma_get_request(url: "users/tutor", output: alma_user.to_json)
    get "/auth/openid_connect/callback"
  end

  context "get /spectrum/mirlyn/get-this/:id/:barcode" do
    before(:each) do
      @mms_id = "990020578280106381"
      @barcode = "39015017893416"
      bib_record = File.read("./spec/fixtures/solr_bib_alma.json")
      stub_request(:get, "#{ENV.fetch("SPECTRUM_CATALOG_SOLR_URL")}/select?q=id:#{@mms_id}&wt=json")
        .to_return(status: 200, body: bib_record, headers: {})
    end
    subject do
      get "/spectrum/mirlyn/get-this/#{@mms_id}/#{@barcode}"
    end
    context "not logged in" do
      it "shows a not logged in profile" do
        expect(JSON.parse(subject.body)["status"]).to eq("Not logged in")
      end
    end
    context "logged in" do
      it "shows a logged in profile" do
        stub_alma_get_request(url: "bibs/990020578280106381/loans", output: {total_record_count: 0}.to_json, query: {limit: 100, offset: 0})
        log_in
        expect(JSON.parse(subject.body)["status"]).to eq("Success")
      end
    end
  end
end
