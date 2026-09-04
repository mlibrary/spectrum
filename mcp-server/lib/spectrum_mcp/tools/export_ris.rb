require "mcp"
require_relative "../client"

module SpectrumMcp
  module Tools
    class ExportRis < MCP::Tool
      tool_name "spectrum_export_ris"
      description "Export one or more records from a Spectrum datastore as RIS citation data (for import into reference managers like Zotero or EndNote)."

      input_schema(
        properties: {
          focus: {
            type: "string",
            enum: SpectrumMcp::Client::FOCI,
            description: "Datastore the records belong to: mirlyn (library catalog), databases, onlinejournals, primo (articles), website"
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
        required: ["focus", "ids"]
      )

      class << self
        def call(focus:, ids:, base_url: "", server_context: nil)
          client = SpectrumMcp::Client.new
          result = client.export_ris(focus: focus, ids: ids, base_url: base_url)
          MCP::Tool::Response.new([{type: "text", text: result}])
        rescue SpectrumMcp::Client::RequestError => e
          MCP::Tool::Response.new([{type: "text", text: e.message}], error: true)
        end
      end
    end
  end
end
