require "mcp"
require "mcp/server/transports/streamable_http_transport"
require_relative "lib/spectrum_mcp/server"

options = {stateless: true, dns_rebinding_protection: false}
options[:allowed_hosts] = ENV["MCP_ALLOWED_HOSTS"].split(",") if ENV["MCP_ALLOWED_HOSTS"]
options[:allowed_origins] = ENV["MCP_ALLOWED_ORIGINS"].split(",") if ENV["MCP_ALLOWED_ORIGINS"]

run MCP::Server::Transports::StreamableHTTPTransport.new(SpectrumMcp.build_server, **options)
