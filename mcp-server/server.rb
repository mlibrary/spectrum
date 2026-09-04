#!/usr/bin/env ruby
require "mcp"
require "mcp/server/transports/stdio_transport"
require_relative "lib/spectrum_mcp/server"

transport = MCP::Server::Transports::StdioTransport.new(SpectrumMcp.build_server)
transport.open
