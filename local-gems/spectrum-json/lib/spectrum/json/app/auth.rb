module Spectrum
  module Json
    class App < Sinatra::Base
      module Auth
        def self.included(app)
          # app.use Rack::Session::Cookie
          app.use OmniAuth::Builder do
            provider :openid_connect, {
              scope: [:openid, :email, :profile],
              issuer: ENV["WEBLOGIN_URL"],
              discovery: true,
              client_auth_method: "jwks",
              client_options: {
                identifier: ENV["WEBLOGIN_ID"],
                secret: ENV["WEBLOGIN_SECRET"],
                redirect_uri: "#{ENV["REACT_APP_LOGIN_BASE_URL"]}/auth/openid_connect/callback"
              }
            }
          end

          app.get("/login") do
            auth_session_new
          end

          app.get("/logout") do
            auth_session_destory
          end

          app.get("/auth/openid_connect/callback") do
            auth_session_create
          end
        end

        def auth_session_create
          username = request.env["omniauth.auth"]["info"]["nickname"]
          session[:username] = username
          query = URI.parse(request.env["omniauth.origin"]).query
          if query.nil? || CGI.parse(query)["dest"].empty?
            redirect "/everything"
          else
            redirect CGI.parse(query)["dest"].first
          end
        end

        def auth_session_new
          erb :login
        end

        def auth_session_destroy
          url = ENV.fetch("REACT_APP_LOGIN_BASE_URL")
          url += params["dest"] if params["dest"]
          # adds trailing slash if needed
          url += "/" unless url.end_with?("/")
          session.clear
          redirect "https://shibboleth.umich.edu/cgi-bin/logout?#{url}"
        end
      end
    end
  end
end
