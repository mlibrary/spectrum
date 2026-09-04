require "mcp"
require_relative "../client"

module SpectrumMcp
  module Tools
    class ExportRis < MCP::Tool
      tool_name "spectrum_export_ris"
      description "Export one or more records from a Spectrum datastore as RIS citation data (for import into reference managers like Zotero or EndNote)."

      input_schema(
        properties: {
          datastore: {
            type: "string",
            enum: SpectrumMcp::Client.datastore_names,
            description: "Name of the datastore the records belong to"
          },
          ids: {
            type: "array",
            items: {type: "string"},
            description: "Record ids to export"
          },
          base_url: {
            type: "string",
            description: "Optional base URL used to build a link back to each record in the exported RIS data"
          }
        },
        required: ["datastore", "ids"]
      )

      class << self
        def call(datastore:, ids:, base_url: "", server_context: nil)
          client = SpectrumMcp::Client.new
          result = client.export_ris(datastore: datastore, ids: ids, base_url: base_url)
          MCP::Tool::Response.new([{type: "text", text: result}])
        rescue SpectrumMcp::Client::RequestError => e
          MCP::Tool::Response.new([{type: "text", text: e.message}], error: true)
        end
      end
    end
  end
end
