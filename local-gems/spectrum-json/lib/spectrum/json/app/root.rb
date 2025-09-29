module Spectrum
  module Json
    class App < Sinatra::Base
      module Root
        def self.included(app)
          app.options("*") do
            cors
          end
          [:get, :post].each do |method|
            app.send(method, "/spectrum") do
              root
            end

            ["/", "/index.html"].each do |path|
              app.send(method, path) do
                manage_cookies
                redirect "/everything"
              end
            end

            app.send(method, "*") do
              manage_cookies
              send_file("public/app.html")
            end
          end
        end

        def list_datastores
          base_url.merge(
            data: Spectrum::Json.foci
          )
        end

        def root
          cors
          spectrum_request = Spectrum::Request::Null.new
          spectrum_response = Spectrum::Response::DataStoreList.new(list_datastores)
          json(basic_response(spectrum_request: spectrum_request, spectrum_response: spectrum_response))
        end
      end
    end
  end
end
