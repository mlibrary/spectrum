#!/usr/bin/env ruby
# frozen_string_literal: true
#
# MCP test client — exercises the stdio MCP server.
#
# Usage:
#   bundle exec ruby script/mcp_client.rb [options]
#
# Options:
#   --transport=stdio|http   Default: stdio
#   --url=URL                Base URL for HTTP transport (default: http://localhost:3000)
#   --token=TOKEN            Bearer token for HTTP transport (optional)
#   --tool=NAME              Call a specific tool by name instead of auto-smoke-test
#   --query=TEXT             Query string for search_* tools (default: "ruby")
#   --id=ID                  Record ID for record_* tools
#   --count=N                Result count for search_* tools (default: 3)
#   --list                   Just list available tools and exit
#   --verbose                Print full JSON responses
#   --debug                  Capture server stderr and print it; show full error details

APP_ROOT = File.expand_path('..', __dir__)
Dir.chdir(APP_ROOT)
File.expand_path("lib", APP_ROOT).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

tmp_argv = ARGV.dup
ARGV.clear

require "bundler/setup"
Bundler.require(:metrics)
Bundler.require(:default)
require "dotenv/load"
require 'optparse'
require 'json'
require 'fileutils'
ARGV.replace(tmp_argv)

options = {
  transport: 'stdio',
  url:       'http://localhost:3000',
  token:     nil,
  tool:      nil,
  query:     'ruby',
  id:        nil,
  count:     3,
  list:      false,
  verbose:   false,
  debug:     false,
}

OptionParser.new do |o|
  o.on('--transport=VAL')    { |v| options[:transport] = v }
  o.on('--url=VAL')          { |v| options[:url] = v }
  o.on('--token=VAL')        { |v| options[:token] = v }
  o.on('--tool=VAL')         { |v| options[:tool] = v }
  o.on('--query=VAL')        { |v| options[:query] = v }
  o.on('--id=VAL')           { |v| options[:id] = v }
  o.on('--count=N', Integer) { |v| options[:count] = v }
  o.on('--list')             { options[:list] = true }
  o.on('--verbose')          { options[:verbose] = true }
  o.on('--debug')            { options[:debug] = true }
end.parse!

APP_ROOT = File.expand_path('..', __dir__)
Dir.chdir(APP_ROOT)
File.expand_path('lib', APP_ROOT).tap { |d| $LOAD_PATH.unshift(d) unless $LOAD_PATH.include?(d) }

require 'dotenv/load'
require 'bundler/setup'
require 'mcp'

# ── helpers ──────────────────────────────────────────────────────────────────

def print_tool_list(tools)
  puts "\n#{"=" * 60}"
  puts "Available tools (#{tools.size})"
  puts "=" * 60
  tools.each do |t|
    puts "  #{t.name}"
    puts "    #{t.description}" if t.description && !t.description.empty?
  end
  puts
end

def print_response(tool_name, response, verbose:)
  puts "\n#{"─" * 60}"
  puts "Tool: #{tool_name}"
  puts "─" * 60
  response.content.each do |block|
    next unless block[:type] == 'text'
    text = block[:text]
    if verbose
      puts text
    else
      begin
        data = JSON.parse(text)
        if data['error']
          puts "  ERROR: #{data['error']}"
        elsif data['total_available']
          puts "  total_available: #{data['total_available']}"
          records = Array(data['records'])
          puts "  records returned: #{records.size}"
          records.first(3).each_with_index do |rec, i|
            title_field = Array(rec).find { |f| f.is_a?(Hash) && f['uid'] == 'title' }
            id_field    = Array(rec).find { |f| f.is_a?(Hash) && f['uid'] == 'id' }
            title = title_field&.dig('value') || '(no title)'
            id    = id_field&.dig('value')    || '(no id)'
            puts "  [#{i + 1}] #{title} (id: #{id})"
          end
        else
          puts "  keys: #{data.keys.first(8).join(', ')}"
        end
      rescue JSON::ParserError
        puts "  #{text[0, 200]}"
      end
    end
  end
end

# ── build transport ───────────────────────────────────────────────────────────

STDERR_LOG = File.join(APP_ROOT, 'log', 'mcp_server_stderr.log')

transport = case options[:transport]
when 'http'
  headers = {}
  headers['Authorization'] = "Bearer #{options[:token]}" if options[:token]
  MCP::Client::HTTP.new(url: "#{options[:url].chomp('/')}/mcp", headers: headers)
when 'stdio'
  server_rb = File.join(APP_ROOT, 'script', 'mcp_server.rb')
  server_env = {}
  if options[:debug]
    FileUtils.mkdir_p(File.dirname(STDERR_LOG))
    File.write(STDERR_LOG, '')
    $stderr.puts "[debug] Server stderr \u2192 #{STDERR_LOG}"
    server_env['MCP_DEBUG_STDERR'] = STDERR_LOG
  end
  MCP::Client::Stdio.new(
    command:      RbConfig.ruby,
    args:         [server_rb],
    env:          server_env,
    read_timeout: options[:debug] ? 60 : 30,
  )
else
  abort "Unknown transport: #{options[:transport]}"
end

client = MCP::Client.new(transport: transport)

begin
  print "Connecting (#{options[:transport]})... "
  client.connect
  puts "OK"

  tools = client.tools
  print_tool_list(tools)
  exit 0 if options[:list]

  tools_to_run = if options[:tool]
    target = tools.find { |t| t.name == options[:tool] }
    abort "Tool '#{options[:tool]}' not found. Run --list to see available tools." unless target
    [target]
  else
    [
      tools.find { |t| t.name.start_with?('search_') },
      tools.find { |t| t.name.start_with?('record_') },
    ].compact
  end

  tools_to_run.each do |tool|
    args = if tool.name.start_with?('search_')
      { query: options[:query], count: options[:count] }
    elsif tool.name.start_with?('record_')
      unless options[:id]
        puts "\n  (skipping #{tool.name} — pass --id=ID to test record lookup)"
        next
      end
      { id: options[:id] }
    else
      puts "\n  (skipping #{tool.name} — use --tool=NAME to target it explicitly)"
      next
    end

    print "Calling #{tool.name} #{args.inspect}... "
    begin
      response = client.call_tool(tool: tool, arguments: args)
      puts "done"
      print_response(tool.name, response, verbose: options[:verbose])
    rescue MCP::Client::ServerError => e
      puts "SERVER ERROR"
      puts "  #{e.class}: #{e.message}"
      if options[:debug]
        stderr_content = File.read(STDERR_LOG) rescue ''
        unless stderr_content.empty?
          puts "\n#{'─' * 60}"
          puts "Server stderr (#{STDERR_LOG}):"
          puts "#{'─' * 60}"
          puts stderr_content
        else
          puts "  (no server stderr captured — check #{STDERR_LOG})"
        end
      else
        puts "  Rerun with --debug to capture server stderr"
      end
    end
  end

ensure
  transport.close rescue nil
end
