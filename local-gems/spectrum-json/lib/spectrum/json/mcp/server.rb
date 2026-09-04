# frozen_string_literal: true

module Spectrum
  module Json
    module Mcp
      # Wraps MCP::Server and registers search/record tools for every
      # configured Spectrum focus/datastore.
      class Server
        # Minimal request stub that satisfies the interface expected by
        # Spectrum::Request::Record and the Solr/Primo engine param-builders.
        class MockRecordRequest
          attr_reader :params, :path, :env

          def initialize(source_id:, id_field:, id:)
            @params = {
              source: source_id,  'source'   => source_id,
              id_field: id_field, 'id_field' => id_field,
              id: id,             'id'       => id,
              type: 'Record',     'type'     => 'Record',
              focus: source_id,   'focus'    => source_id,
            }
            @path = "/spectrum/#{source_id}/record/#{id}"
            @env  = {}
          end
        end

        def initialize(name: 'spectrum-search', version: '1.0.0')
          @mcp_server = MCP::Server.new(name: name, version: version)
          register_tools!
        end

        def open
          to_stdio_transport.open
        end

        def to_stdio_transport
          MCP::Server::Transports::StdioTransport.new(@mcp_server)
        end

        def to_http_transport(**opts)
          MCP::Server::Transports::StreamableHTTPTransport.new(@mcp_server, **opts)
        end

        private

        def register_tools!
          return unless Spectrum::Json.foci && Spectrum::Json.sources

          Spectrum::Json.foci.each_value do |focus|
            source = Spectrum::Json.sources[focus.source]
            next unless source

            register_search_tool!(focus, source)
            register_record_tool!(focus, source)
          end
        end

        def register_search_tool!(focus, source)
          focus_id   = focus.id
          label      = focus.metadata&.name || focus_id
          short_desc = focus.metadata&.short_desc
          base       = { base_url: Spectrum::Json.base_url }

          @mcp_server.define_tool(
            name: "search_#{focus_id}",
            description: [
              "Search #{label}.",
              short_desc,
              'Returns JSON with total_available (integer) and records (array).',
            ].compact.join(' '),
            input_schema: {
              type: 'object',
              properties: {
                query: { type: 'string',  description: 'Search query string' },
                start: { type: 'integer', description: 'Zero-based result offset (default: 0)' },
                count: { type: 'integer', description: 'Number of results to return (default: 10)' },
              },
              required: ['query'],
            },
          ) do |args, server_context:|
            query = args[:query] || args['query']
            start = (args[:start] || args['start'] || 0).to_i
            count = (args[:count] || args['count'] || 10).to_i

            request_data = { 'uid' => focus_id, 'start' => start, 'count' => count }
            if focus.new_parser?
              request_data['raw_query'] = query
            else
              request_data['field_tree'] = { 'type' => 'literal', 'value' => query }
            end

            spectrum_request  = Spectrum::Request::DataStore.new(request_data, focus)
            engine            = source.engine(focus, spectrum_request, nil)
            specialists       = Spectrum::Response::Specialists.new(
              base.merge(request: spectrum_request, source: source, focus: focus),
            )
            spectrum_response = Spectrum::Response::RecordList.new(
              base.merge(
                data:            engine.results,
                source:          source,
                focus:           focus,
                total_available: engine.total_items,
                specialists:     specialists,
              ),
              spectrum_request,
            )

            result = { total_available: engine.total_items, records: spectrum_response.spectrum }
            MCP::Tool::Response.new([{ type: 'text', text: JSON.generate(result) }])
          rescue => e
            MCP::Tool::Response.new(
              [{ type: 'text', text: JSON.generate({ error: e.message }) }],
              error: true,
            )
          end
        end

        def register_record_tool!(focus, source)
          focus_id = focus.id
          label    = focus.metadata&.name || focus_id
          base     = { base_url: Spectrum::Json.base_url }

          @mcp_server.define_tool(
            name: "record_#{focus_id}",
            description: "Fetch a single #{label} record by ID. Returns the full record with holdings.",
            input_schema: {
              type: 'object',
              properties: {
                id: { type: 'string', description: 'Record ID' },
              },
              required: ['id'],
            },
          ) do |args, server_context:|
            id           = args[:id] || args['id']
            mock_request = MockRecordRequest.new(
              source_id: source.id,
              id_field:  focus.id_field,
              id:        id,
            )

            spectrum_request = Spectrum::Request::Record.new(mock_request)
            engine           = source.engine(focus, spectrum_request, nil)

            result = if engine.total_items > 0
              spectrum_response = Spectrum::Response::Record.new(
                base.merge(data: engine.results.first, source: source, focus: focus),
                spectrum_request,
              )
              holdings_response = if source.holdings
                Spectrum::Response::Holdings.new(
                  source,
                  Spectrum::Request::Holdings.new(mock_request.params),
                )
              else
                Spectrum::Response::NullHoldings.new
              end
              spectrum_response.spectrum.merge(holdings: holdings_response.renderable)
            else
              {}
            end

            MCP::Tool::Response.new([{ type: 'text', text: JSON.generate(result) }])
          rescue => e
            MCP::Tool::Response.new(
              [{ type: 'text', text: JSON.generate({ error: e.message }) }],
              error: true,
            )
          end
        end
      end
    end
  end
end
