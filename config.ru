# This file is used by Rack-based servers to start the application.
#ENV['RAILS_RELATIVE_URL_ROOT'] = "/testapp/spectrum"

require ::File.expand_path('../config/environment',  __FILE__)

::BLACKLIGHT_VERBOSE_LOGGING=true

use Rack::ReverseProxy do
  reverse_proxy %r{^/browse.css}, "https://#{ENV['BROWSE_HOST']}/$1"
  reverse_proxy %r{^/catalog/browse/(.*)$}, "https://#{ENV['BROWSE_HOST']}/$1"
end

run Clio::Application

