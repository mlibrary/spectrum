# This file is used by Rack-based servers to start the application.
File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

ENV['APP_ENV'] ||= ENV['RAILS_ENV']

# If yabeda will try to use Railties if Rails is defined.
# rails-html-sanitizer defines Rails, and is used in spectrum.
# Thus Yabeda has to be loaded before everything else.
require "bundler"
Bundler.require :yabeda
Bundler.require

require "prometheus/middleware/collector"

if (monitoring_dir = ENV["PROMETHEUS_MONITORING_DIR"])
  FileUtils.mkdir_p(monitoring_dir)
  Dir[File.join(monitoring_dir, "*.bin")].each do |file_path|
    File.unlink(file_path)
  end
  Prometheus::Client.config.data_store =
    Prometheus::Client::DataStores::DirectFileStore.new( dir: monitoring_dir )
end

Yabeda.configure!
use Prometheus::Middleware::Collector

Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

use Rack::ReverseProxy do
  reverse_proxy %r{^/browse.css}, "https://#{ENV["BROWSE_HOST"]}/$1"
  reverse_proxy %r{^/catalog/browse/(.*)$}, "https://#{ENV["BROWSE_HOST"]}/$1"
end

run Spectrum::Json::App
