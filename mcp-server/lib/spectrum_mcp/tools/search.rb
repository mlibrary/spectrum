require "mcp"
require_relative "../client"

module SpectrumMcp
  module Tools
    class Search < MCP::Tool
      tool_name "spectrum_search"
      description "Search a Spectrum datastore (catalog, databases, online journals, articles, or the library website) and return matching records."

      input_schema(
        properties: {
          datastore: {
            type: "string",
            enum: SpectrumMcp::Client.datastore_names,
            description: "Name of the datastore to search"
          },
          query: {
            type: "string",
            description: "Search query, e.g. 'psychology' or field-qualified syntax like 'title:(foo) AND author:(bar)'"
          },
          start: {
            type: "integer",
            description: "0-based index of the first result to return",
            default: 0
          },
          count: {
            type: "integer",
            description: "Number of results to return",
            default: 10
          },
          sort: {
            type: "string",
            description: "Sort uid, e.g. relevance, date_desc, date_asc, title_asc, title_desc, author_asc, author_desc"
          },
          filters: {
            type: "object",
            description: "Facet filters to narrow results, keyed by facet name (e.g. format, subject, language, publication_date). Each value is either a single string or an array of strings. All filters are AND'd together; when a facet has multiple values, a result must match all of them (not just one), so only combine multiple values for a facet that can hold more than one at once (e.g. a record with both a Book and a CDROM format). Example: {\"format\": [\"Book\", \"CDROM\"]}",
            additionalProperties: {
              oneOf: [
                {type: "string"},
                {type: "array", items: {type: "string"}}
              ]
            }
          }
        },
        required: ["datastore", "query"]
      )

      class << self
        def call(datastore:, query:, start: 0, count: 10, sort: nil, filters: {}, server_context: nil)
          client = SpectrumMcp::Client.new
          result = client.search(datastore: datastore, query: query, start: start, count: count, sort: sort, filters: filters)
          MCP::Tool::Response.new([{type: "text", text: result.to_json}], structured_content: result)
        rescue SpectrumMcp::Client::RequestError => e
          MCP::Tool::Response.new([{type: "text", text: e.message}], error: true)
        end
      end
    end
  end
end
