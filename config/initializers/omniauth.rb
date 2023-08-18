require "omniauth"
require "omniauth_openid_connect"

# Monkey patch to use system level certificate store
# https://github.com/nahi/httpclient/issues/445
require "httpclient"

class HTTPClient
  alias_method :original_initialize, :initialize

  def initialize(*args, &block)
    original_initialize(*args, &block)
    # Force use of the default system CA certs (instead of the 6 year old bundled ones)
    @session_manager&.ssl_config&.set_default_paths
  end
end

# OmniAuth::AuthenticityTokenProtection.default_options(key: "csrf.token", authenticity_param: "_csrf")

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    scope: [:openid, :email, :profile],
    issuer: "https://weblogin.lib.umich.edu",
    discovery: true,
    client_auth_method: "jwks",
    client_options: {
      identifier: ENV["WEBLOGIN_ID"],
      secret: ENV["WEBLOGIN_SECRET"],
      redirect_uri: "http://localhost:3000/auth/openid_connect/callback"
    }
  }
end
