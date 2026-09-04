require "mcp"
require_relative "../client"

module SpectrumMcp
  module Tools
    class GetRecord < MCP::Tool
      tool_name "spectrum_get_record"
      description "Fetch a single record from a Spectrum datastore by its record id."

      input_schema(
        properties: {
          datastore: {
            type: "string",
            enum: SpectrumMcp::Client.datastore_names,
            description: "Name of the datastore the record belongs to"
          },
          id: {
            type: "string",
            description: "The record id (e.g. the uid returned by spectrum_search)"
          }
        },
        required: ["datastore", "id"]
      )

      class << self
        def call(datastore:, id:, server_context: nil)
          client = SpectrumMcp::Client.new
          result = client.record(datastore: datastore, id: id)
          MCP::Tool::Response.new([{type: "text", text: result.to_json}])
        rescue SpectrumMcp::Client::RequestError => e
          MCP::Tool::Response.new([{type: "text", text: e.message}], error: true)
        end
      end
    end
  end
end
