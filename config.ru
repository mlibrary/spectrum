# This file is used by Rack-based servers to start the application.
File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

ENV["APP_ENV"] ||= ENV["RAILS_ENV"]

if ENV["PROMETHEUS_EXPORTER_URL"]
  # Prometheus::Middleware::Collector.new has side effects that registers
  # metrics.  If they are already loaded it raises an exception.
  if Prometheus::Client.registry.exist?(:http_server_requests_total)
    Prometheus::Client.registry.unregister(:http_server_requests_total)
    Prometheus::Client.registry.unregister(:http_server_request_duration_seconds)
    Prometheus::Client.registry.unregister(:http_server_exceptions_total)
  end
  use Prometheus::Middleware::Collector
end

Bundler.require
Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

use Rack::ReverseProxy do
  reverse_proxy %r{^/browse.css}, "https://#{ENV["BROWSE_HOST"]}/$1"
  reverse_proxy %r{^/catalog/browse/(.*)$}, "https://#{ENV["BROWSE_HOST"]}/$1"
end

run Spectrum::Json::App
