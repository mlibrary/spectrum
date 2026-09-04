require "mcp"
require_relative "../client"

module SpectrumMcp
  module Tools
    class GetRecord < MCP::Tool
      tool_name "spectrum_get_record"
      description "Fetch a single record from a Spectrum datastore by its record id."

      input_schema(
        properties: {
          focus: {
            type: "string",
            enum: SpectrumMcp::Client.foci,
            description: "Datastore the record belongs to: mirlyn (library catalog), databases, onlinejournals, primo (articles), website"
          },
          id: {
            type: "string",
            description: "The record id (e.g. the uid returned by spectrum_search)"
          }
        },
        required: ["focus", "id"]
      )

      class << self
        def call(focus:, id:, server_context: nil)
          client = SpectrumMcp::Client.new
          result = client.record(focus: focus, id: id)
          MCP::Tool::Response.new([{type: "text", text: result.to_json}])
        rescue SpectrumMcp::Client::RequestError => e
          MCP::Tool::Response.new([{type: "text", text: e.message}], error: true)
        end
      end
    end
  end
end
