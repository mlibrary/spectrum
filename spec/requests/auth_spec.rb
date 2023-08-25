require "rails_helper"

RSpec.describe "Auth routes", type: :request do
  context "get /auth/openid_connect/callback" do
    before(:each) do
      @omniauth_auth = {
        info: {nickname: "tutor"}
      }
      @origin = "/login?dest=/somewhere"
      stub_alma_get_request(url: "users/tutor", output: File.read("./spec/fixtures/alma_user.json"))
    end
    subject do
      OmniAuth.config.add_mock(:openid_connect, @omniauth_auth)
      OmniAuth.config.before_callback_phase do |env|
        env["omniauth.origin"] = @origin
      end
      get "/auth/openid_connect/callback"
    end
    it "sets the username from the callback" do
      get "/spectrum/profile"
      expect(JSON.parse(response.body)["status"]).to eq("Not logged in")
      subject
      get "/spectrum/profile"
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("Logged in")
      expect(body["email"]).to eq("tutor@umich.edu")
    end

    it "redirects to the dest parameter" do
      subject
      expect(response).to redirect_to "/somewhere"
    end

    it "redirects to /everything if no dest parameter" do
      @origin = "/login?not_a_dest=not_used_anywhere"
      subject
      expect(response).to redirect_to "/everything"
    end

    it "redirects to /everything if no parameters whatsover" do
      @origin = "/login"
      subject
      expect(response).to redirect_to "/everything"
    end
  end

  context "get /login" do
    it "renders page with Logging you in" do
      get "/login"
      expect(response.body).to include("Logging you in")
    end
  end

  context "get /logout" do
    it "resets the session" do
      # set up the logged in session
      stub_alma_get_request(url: "users/tutor", output: File.read("./spec/fixtures/alma_user.json"))
      OmniAuth.config.add_mock(:openid_connect, {info: {nickname: "tutor"}})
      OmniAuth.config.before_callback_phase do |env|
        env["omniauth.origin"] = "/login"
      end
      get "/auth/openid_connect/callback"

      get "/login"
      # verify that we are indeed logged in
      get "/spectrum/profile"
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("Logged in")

      # the actual thing we are testing
      get "/logout"
      get "/spectrum/profile"
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("Not logged in")
    end

    it "redirects to shibboleth logout url with search redirect" do
      get "/logout"
      expect(response).to redirect_to "https://shibboleth.umich.edu/cgi-bin/logout?#{ENV.fetch("REACT_APP_LOGIN_BASE_URL")}/"
    end

    it "redirects to logout with redirect back to dest url" do
      get "/logout?dest=/somewhere/"
      expect(response).to redirect_to "https://shibboleth.umich.edu/cgi-bin/logout?#{ENV.fetch("REACT_APP_LOGIN_BASE_URL")}/somewhere/"
    end
  end
end
