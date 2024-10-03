module Spectrum
  module Json
    class App < Sinatra::Base
      module Act
        def self.included(app)
          app.post("/spectrum/email") do
            act(request_class: Spectrum::Request::Email, response_class: Spectrum::Response::Email)
          end

          app.post("/spectrum/text") do
            act(request_class: Spectrum::Request::Text, response_class: Spectrum::Response::Text)
          end

          app.post("/spectrum/file") do
            act_file(request_class: Spectrum::Request::File, response_class: Spectrum::Response::File)
          end
        end

        def act(request_class:, response_class:)
          json(response_class.new(request_class.new(request: request, username: session[:username])).spectrum)
        end

        def act_file(request_class:, response_class:)
          headers["Content-type"] = "application/x-research-info-systems"
          headers["Content-Disposition"] = "attachment;filename=Library Search Record Export.ris"
          response_class.new(request_class.new(request)).data
        end
      end
    end
  end
end
