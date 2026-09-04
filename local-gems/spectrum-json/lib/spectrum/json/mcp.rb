# frozen_string_literal: true

require 'mcp'
require 'json'

module Spectrum
  module Json
    module Mcp
      class << self
        # Returns the shared MCP server, creating it on first call.
        # Foci and sources must be configured before this is called.
        def server
          @server ||= Server.new(base_url: Spectrum::Json.base_url.to_s)
        end

        # Returns the shared StreamableHTTPTransport for mounting in Rack.
        def http_transport
          @http_transport ||= server.to_http_transport
        end
      end
    end
  end
end

require_relative 'mcp/server'
require_relative 'mcp/dispatcher'
