module Spectrum
  module Json
    class App < Sinatra::Base
      module Middleware
        def self.included(app)
          app.use Ipresolver::Middleware, proxies: [
            "127.0.0.0/16",
            "141.211.168.128/25",
            "141.213.128.128/25",
            "10.255.0.0/16"
          ]

          app.use Keycard::Rack::InjectAttributes, Keycard::Yaml::InstitutionFinder.new
          app.use Keycard::Rack::InjectAttributes, Keycard::Cookie::InstitutionFinder.new
          app.use Keycard::Rack::InjectAttributes, Keycard::Ldap::InstitutionFinder.new
        end
      end
    end
  end
end
