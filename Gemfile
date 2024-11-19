source "https://rubygems.org"
# I'm getting deployment errors with capistrano about trying to load pry
gem "pry"
gem "down"
gem "ostruct"
gem "logger"

gem "rack-reverse-proxy", require: "rack/reverse_proxy"

# Allow dotenv configuration
gem "dotenv", require: "dotenv/load"
gem "activesupport", "~> 7.1.4"
gem "sinatra"
gem "sinatra-contrib", require: "sinatra/json"

# Rails::Html::Sanitizer doesn't actually depend on Rails
gem "rails-html-sanitizer"

gem "skylight"
gem "net-ldap"
gem "twilio-ruby"
gem "puma"
gem "parslet"

gem "omniauth"
gem "omniauth_openid_connect"

gem "ipresolver",
  git: "https://github.com/mlibrary/ipresolver",
  branch: "master"

gem "keycard",
  git: "https://github.com/bertrama/keycard",
  branch: "rack-yaml-institution-finder",
  require: ["keycard/rack", "keycard/yaml/institution_finder"]

gem "spectrum-config", path: "local-gems/spectrum-config"

gem "spectrum-json", path: "local-gems/spectrum-json"

gem "alma_rest_client",
  git: "https://github.com/mlibrary/alma_rest_client",
  tag: "1.0.1"

gem "mlibrary_search_parser",
  git: "https://github.com/mlibrary/mlibrary_search_parser",
  branch: "main"

gem "json"

gem "httpclient"
gem "nokogiri"

group :yabeda do
  gem "yabeda-puma-plugin"
  gem "yabeda-prometheus"
  gem "prometheus-client", require: "prometheus/middleware/collector"
end

# "Rack middleware which cleans up invalid UTF8 characters"
# gem 'rack-utf8_sanitizer'
# Use github master branch, to pick up a few new patches.
# Maybe this will fix one of our outstanding issues:
#    application#catch_404s (ArgumentError) "invalid %-encoding"
# We also still have invalid %-encoding w/submitted form fields.
# This is an open issue at rack-utf8_sanitizer.
# gem 'rack-utf8_sanitizer', :github => 'whitequark/rack-utf8_sanitizer'
gem "rack-utf8_sanitizer", git: "https://github.com/whitequark/rack-utf8_sanitizer", branch: "main"

group :test, :development do
  gem "pry-byebug"
  gem "standard"
  gem "simplecov"
  gem "webmock"
  gem "rspec"
  gem "rack-test"
  gem "fiddle"
end
