# This file is used by Rack-based servers to start the application.
File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

ENV["APP_ENV"] ||= ENV["RAILS_ENV"]

if ENV["PROMETHEUS_EXPORTER_URL"]
  use Prometheus::Middleware::Collector
end

Bundler.require
Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

use Rack::ReverseProxy do
  reverse_proxy %r{^/browse.css}, "https://#{ENV["BROWSE_HOST"]}/$1"
  reverse_proxy %r{^/catalog/browse/(.*)$}, "https://#{ENV["BROWSE_HOST"]}/$1"
end

use Rack::Attack
ENV.fetch("RACK_IP_BLOCKLIST", "").split(/\s/).each do |ip|
  Rack::Attack.blocklist_ip(ip)
end

if (redis_url =  ENV.fetch("RACK_ATTACK_REDIS_URL", false))
  Rack::Attack.cache.store = Redis.new(url: redis_url)
  Rack::Attack.throttle(
    "requests by ip",
    limit: ENV.fetch("RACK_ATTACK_THROTTLE_LIMIT", 10),
    period: ENV.fetch("RACK_ATTACK_THROTLE_PERIOD", 15)
  ) do |request|
    request.ip
  end
end

run Spectrum::Json::App
