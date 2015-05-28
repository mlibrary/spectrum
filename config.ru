# This file is used by Rack-based servers to start the application.
#ENV['RAILS_RELATIVE_URL_ROOT'] = "/testapp/spectrum"

require ::File.expand_path('../config/environment',  __FILE__)

if false
  use LIT::Rack::Env do |env|
    if env['REQUEST_URI'].start_with? env['SCRIPT_NAME']
      env['REQUEST_URI'].slice!(0, env['SCRIPT_NAME'].length)
      env['SCRIPT_NAME'] = ENV['RAILS_RELATIVE_URL_ROOT'] || ''
    end
    env
  end
end

run Clio::Application

