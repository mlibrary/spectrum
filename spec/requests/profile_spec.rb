require "rails_helper"

RSpec.describe "Profile routes", type: :request do
  context "get /profile" do
    subject do
      get "/spectrum/profile"
    end
    context "not logged in" do
      it "shows a not logged in profile" do
        subject
        expect(JSON.parse(response.body)["status"]).to eq("Not logged in")
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
        subject
        expect(JSON.parse(response.body)["status"]).to eq("Logged in")
        expect(JSON.parse(response.body)["email"]).to eq("tutor@umich.edu")
      end
    end
  end
end
