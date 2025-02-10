# This file is used by Rack-based servers to start the application.
File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

ENV["APP_ENV"] ||= ENV["RAILS_ENV"]

if ENV["PUMA_CONTROL_APP"] && ENV["PROMETHEUS_EXPORTER_URL"]
  use Metrics::Middleware
end

Bundler.require
Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

require 'alma_rest_client/monkey_patch'

use Rack::ReverseProxy do
  reverse_proxy %r{^/browse.css}, "https://#{ENV["BROWSE_HOST"]}/$1"
  reverse_proxy %r{^/catalog/browse/(.*)$}, "https://#{ENV["BROWSE_HOST"]}/$1"
end

use Rack::Attack
ENV.fetch("RACK_IP_BLOCKLIST", "").split(/\s/).each do |ip|
  Rack::Attack.blocklist_ip(ip)
end

if ENV.fetch("RACK_THROTTLE", false)
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  Rack::Attack.throttle('limit requests for /spectrum/.*/record', limit: 3, period: 60) do |req|
    if req.path.match(%r{/spectrum/.*/record/})
      req.ip
    end
  end
end

run Spectrum::Json::App
