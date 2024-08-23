module Spectrum
  module Json
    class App < Sinatra::Base
      module Profile
        def self.included(app)
          [:get, :post].each do |method|
            app.send(method, "/spectrum/profile") do
              profile(request_class: Spectrum::Request::Profile, response_class: Spectrum::Response::Profile)
            end
          end
        end

        def profile(request_class:, response_class:)
          cors
          no_cache
          json(response_class.new(request_class.new(request: request, username: session[:username])).spectrum)
        end
      end
    end
  end
end
