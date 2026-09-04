#!/usr/bin/env ruby
require "mcp"
require "mcp/server/transports/stdio_transport"
require_relative "lib/spectrum_mcp/tools/search"
require_relative "lib/spectrum_mcp/tools/get_record"
require_relative "lib/spectrum_mcp/tools/export_ris"

server = MCP::Server.new(
  name: "spectrum",
  tools: [
    SpectrumMcp::Tools::Search,
    SpectrumMcp::Tools::GetRecord,
    SpectrumMcp::Tools::ExportRis
  ]
)

transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
