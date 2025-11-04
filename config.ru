# This file is used by Rack-based servers to start the application.
File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

ENV["APP_ENV"] ||= ENV["RAILS_ENV"]

Bundler.require
require 'redirect_middleware'
use Rack::Timeout, service_timeout: ENV.fetch("RACK_TIMEOUT", 60).to_i
Rack::Timeout::Logger.logger = Logger.new(STDOUT)
Rack::Timeout::Logger.logger.level = Logger::Severity::WARN
use Metrics::Middleware

Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

use Rack::ReverseProxy do
  reverse_proxy %r{^/browse.css}, "https://#{ENV["BROWSE_HOST"]}/$1"
  reverse_proxy %r{^/catalog/browse/(.*)$}, "https://#{ENV["BROWSE_HOST"]}/$1"
end

if ENV.fetch("PROXY_ACME_CHALLENGE", false)
  class SetHostHeader
    def initialize(app)
      @app = app
    end
    def call(env)
      if env["PATH_INFO"].start_with?("/.well-known/acme-challenge/")
        env["SERVER_NAME"] = "search.lib.umich.edu"
        env["HTTP_HOST"] = "search.lib.umich.edu"
      end
      @app.call(env)
    end
  end
  use SetHostHeader
  use Rack::ReverseProxy do
    reverse_proxy_options verify_mode: OpenSSL::SSL::VERIFY_NONE
    reverse_proxy %r{^/.well-known/acme-challenge/(.*)$},
      "https://141.213.128.214/.well-known/acme-challenge/$1",
       preserve_host: false
  end
end

use Rack::Attack

Rack::Attack.track("haz_cookie") do |req|
  req.env.has_key?("HTTP_COOKIE")
end

ENV.fetch("RACK_IP_BLOCKLIST", "").split(/\s/).each do |ip|
  Rack::Attack.blocklist_ip(ip)
end

if ENV.fetch("RACK_THROTTLE", false)
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  Rack::Attack.throttle("limit requests for /spectrum/.*/record", limit: 3, period: 60) do |req|
    if %r{/spectrum/.*/record/}.match?(req.path)
      req.ip
    end
  end
end

limits = RLimit.get(RLimit::NOFILE)
if limits[0] < limits[1]
  RLimit.set(RLimit::NOFILE, limits[1])
end

use RedirectMiddleware
use Rack::RewindableInput::Middleware
run Spectrum::Json::App
