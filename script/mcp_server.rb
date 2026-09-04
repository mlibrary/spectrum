#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Stdio MCP server exposing Spectrum search and record tools.
#
# Usage:
#   bundle exec ruby script/mcp_server.rb

APP_ROOT = File.expand_path('..', __dir__)
Dir.chdir(APP_ROOT)
File.expand_path("lib", APP_ROOT).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

require 'dotenv/load'
require 'bundler/setup'
Bundler.require(:metrics)
Bundler.require(:default)

Spectrum::Json.configure(APP_ROOT, ENV.fetch('RAILS_RELATIVE_URL_ROOT', ''))

Spectrum::Json::Mcp::Server.new(
  base_url: ENV.fetch('RAILS_RELATIVE_URL_ROOT', ''),
).to_stdio_transport.open
