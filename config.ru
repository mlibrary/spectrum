# This file is used by Rack-based servers to start the application.
#ENV['RAILS_RELATIVE_URL_ROOT'] = "/testapp/spectrum"

require ::File.expand_path('../config/environment',  __FILE__)

::BLACKLIGHT_VERBOSE_LOGGING=true

run Clio::Application

