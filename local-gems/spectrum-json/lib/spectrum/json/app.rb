require "spectrum/json/app/common"
require "spectrum/json/app/middleware"
require "spectrum/json/app/root"
require "spectrum/json/app/search"
require "spectrum/json/app/act"
require "spectrum/json/app/holdings"
require "spectrum/json/app/profile"
require "spectrum/json/app/auth"

require "keycard/cookie/institution_finder"
require "keycard/ldap/institution_finder"

module Spectrum
  module Json
    class App < Sinatra::Base
      include Common
      include Middleware
      include Search
      include Act
      include Holdings
      include Profile
      include Auth
      include Root

      configure do
        enable :sessions
        set :session_secret, ENV["RACK_SESSION_SECRET"]
        set :relative_url_root, ENV.fetch("RAILS_RELATIVE_URL_ROOT", "http://localhost:3000")
        set :public_folder, "public"
        set :protection, except: [:json_csrf]
        set :views, File.expand_path(File.join('app', 'views'), __dir__)
      end
    end
  end
end
