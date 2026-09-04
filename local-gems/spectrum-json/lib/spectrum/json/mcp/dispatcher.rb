# frozen_string_literal: true

module Spectrum
  module Json
    module Mcp
      # Rack middleware that routes requests under /mcp to the MCP
      # StreamableHTTPTransport, passing all other requests down the stack.
      #
      # The transport is created lazily on first request (after Spectrum::Json
      # has been configured), so this is safe to add during app setup.
      class Dispatcher
        PATH = '/mcp'

        def initialize(app)
          @app       = app
          @transport = Spectrum::Json::Mcp.http_transport
        end

        def call(env)
          path_info = env['PATH_INFO']
          if path_info == PATH || path_info.start_with?("#{PATH}/")
            @transport.call(env.merge(
              'SCRIPT_NAME' => env['SCRIPT_NAME'].to_s + PATH,
              'PATH_INFO'   => path_info[PATH.length..].then { |s| s.empty? ? '/' : s },
            ))
          else
            @app.call(env)
          end
        end
      end
    end
  end
end
