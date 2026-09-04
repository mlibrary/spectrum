require "mcp"
require_relative "../client"

module SpectrumMcp
  module Tools
    class ListFilters < MCP::Tool
      tool_name "spectrum_list_filters"
      description "List the facet filters available for a Spectrum datastore, with their most common values and counts, for use with spectrum_search's filters parameter."

      input_schema(
        properties: {
          datastore: {
            type: "string",
            enum: SpectrumMcp::Client.datastore_names,
            description: "Name of the datastore to list filters for"
          }
        },
        required: ["datastore"]
      )

      class << self
        def call(datastore:, server_context: nil)
          client = SpectrumMcp::Client.new
          result = client.list_filters(datastore: datastore)
          MCP::Tool::Response.new([{type: "text", text: result.to_json}])
        rescue SpectrumMcp::Client::RequestError => e
          MCP::Tool::Response.new([{type: "text", text: e.message}], error: true)
        end
      end
    end
  end
end
