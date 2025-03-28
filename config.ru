# This file is used by Rack-based servers to start the application.
File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

ENV["APP_ENV"] ||= ENV["RAILS_ENV"]

Bundler.require
use Rack::Timeout, service_timeout: 600
Rack::Timeout::Logger.logger = Logger.new(STDOUT)
Rack::Timeout::Logger.logger.level = Logger::Severity::WARN
use Metrics::Middleware

Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

use Rack::ReverseProxy do
  reverse_proxy %r{^/browse.css}, "https://#{ENV["BROWSE_HOST"]}/$1"
  reverse_proxy %r{^/catalog/browse/(.*)$}, "https://#{ENV["BROWSE_HOST"]}/$1"
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

use Rack::RewindableInput::Middleware
run Spectrum::Json::App
