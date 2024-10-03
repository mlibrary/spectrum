module Spectrum
  module Json
    class App < Sinatra::Base
      module Holdings
        def holdings(source:, focus:)
          cors
          spectrum_request = Spectrum::Request::Holdings.new(request)
          spectrum_response = Spectrum::Response::Holdings.new(source, spectrum_request)
          json(spectrum_response.renderable)
        end

        def hold(source:, focus:)
          cors
          spectrum_request = Spectrum::Request::PlaceHold.new(request: request, username: session[:username])
          spectrum_response = Spectrum::Response::PlaceHold.new(spectrum_request)
          json(spectrum_response.renderable)
        end

        def hold_redirect(source:, focus:)
          cors
          spectrum_request = Spectrum::Request::PlaceHold.new(request: request, username: session[:username])
          Spectrum::Response::PlaceHold.new(spectrum_request).renderable
          redirect("https://www.lib.umich.edu/my-account/holds-recalls", status: 302)
        end

        def get_this(source:, focus:)
          cors
          spectrum_request = Spectrum::Request::GetThis.new(request: request, username: session[:username])
          spectrum_response = Spectrum::Response::GetThis.new(source: source, request: spectrum_request)
          json(spectrum_response.renderable)
        end
      end
    end
  end
end
