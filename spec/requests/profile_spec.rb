require "spec_helper"

RSpec.describe "Profile routes", type: :request do
  include Rack::Test::Methods
  let(:app) { Spectrum::Json::App }
  context "get /profile" do
    subject do
      get "/spectrum/profile"
    end
    context "not logged in" do
      it "shows a not logged in profile" do
        expect(JSON.parse(subject.body)["status"]).to eq("Not logged in")
      end
    end
    context "logged in" do
      it "shows a logged in profile" do
        OmniAuth.config.add_mock(:openid_connect, {info: {nickname: "tutor"}})
        OmniAuth.config.before_callback_phase do |env|
          env["omniauth.origin"] = "/login"
        end
        stub_alma_get_request(url: "users/tutor", output: File.read("./spec/fixtures/alma_user.json"))
        get "/auth/openid_connect/callback"
        expect(JSON.parse(subject.body)["status"]).to eq("Logged in")
        expect(JSON.parse(subject.body)["email"]).to eq("tutor@umich.edu")
      end
    end
  end
end
