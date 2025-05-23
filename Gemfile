source "https://rubygems.org"
# I'm getting deployment errors with capistrano about trying to load pry
gem "pry"
gem "down"
gem "ostruct"
gem "logger"

gem "rack-attack"
gem "rack-timeout"

# Allow dotenv configuration
gem "dotenv", require: "dotenv/load"
# gem "activesupport", "~> 7.1.4"
gem "sinatra"
gem "sinatra-contrib", require: "sinatra/json"

# Rails::Html::Sanitizer doesn't actually depend on Rails
gem "rails-html-sanitizer"

gem "skylight"
gem "net-ldap"
gem "twilio-ruby"
gem "puma"

gem "omniauth"
gem "omniauth_openid_connect"

gem "ipresolver",
  git: "https://github.com/mlibrary/ipresolver",
  branch: "master"

gem "keycard",
  path: "local-gems/keycard",
  require: ["keycard/rack", "keycard/yaml/institution_finder"]

gem "rack-reverse-proxy",
  path: "local-gems/rack-reverse-proxy",
  require: "rack/reverse_proxy"

gem "spectrum-config", path: "local-gems/spectrum-config"

gem "spectrum-json", path: "local-gems/spectrum-json"

gem "alma_rest_client",
  git: "https://github.com/mlibrary/alma_rest_client",
  tag: "alma_rest_client/v2.2.0"

gem "mlibrary_search_parser",
  git: "https://github.com/mlibrary/mlibrary_search_parser",
  branch: "main"

gem "json"

gem "httpclient"
gem "nokogiri"
gem "rlimit"

group :metrics do
  gem "yabeda-puma-plugin"
  gem "yabeda-prometheus"
  gem "prometheus-client", require: File.expand_path(File.join(["lib", "metrics"]), __dir__)
end

group :test, :development do
  gem "pry-byebug"
  gem "standard"
  gem "simplecov"
  gem "webmock"
  gem "rspec"
  gem "rack-test"
  gem "fiddle"
end
