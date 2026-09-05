require "mcp"
require_relative "tools/search"
require_relative "tools/get_record"
require_relative "tools/export_ris"
require_relative "tools/list_filters"

module SpectrumMcp
  def self.build_server
    MCP::Server.new(
      name: "spectrum",
      tools: [
        Tools::Search,
        Tools::GetRecord,
        Tools::ExportRis,
        Tools::ListFilters
      ]
    )
  end
end
