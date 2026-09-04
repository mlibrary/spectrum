require "net/http"
require "json"
require "uri"
require "cgi"

module SpectrumMcp
  # HTTP client for the subset of the Spectrum Sinatra API this MCP server wraps.
  # Callers refer to datastores by their human-readable name; Spectrum's internal
  # uids (mirlyn, primo, etc.) are resolved internally and never exposed.
  class Client
    class RequestError < StandardError; end

    # Fallback used only if the live /spectrum endpoint can't be reached at load time.
    DEFAULT_DATASTORES = {
      "Catalog" => "mirlyn",
      "Databases" => "databases",
      "Online Journals" => "onlinejournals",
      "Articles" => "primo",
      "Guides and more" => "website"
    }.freeze

    # Hash of {datastore name => Spectrum uid}
    def self.datastores(base_url: ENV.fetch("SPECTRUM_BASE_URL", "http://localhost:3000"))
      @datastores ||= begin
        data = new(base_url: base_url).send(:get_json, "/spectrum")
        data.fetch("response").each_with_object({}) do |datastore, hash|
          hash[datastore.fetch("metadata").fetch("name")] = datastore.fetch("uid")
        end
      rescue => e
        warn "spectrum-mcp: falling back to default datastore list (#{e.message})"
        DEFAULT_DATASTORES
      end
    end

    def self.datastore_names(base_url: ENV.fetch("SPECTRUM_BASE_URL", "http://localhost:3000"))
      datastores(base_url: base_url).keys
    end

    def initialize(base_url: ENV.fetch("SPECTRUM_BASE_URL", "http://localhost:3000"))
      @base_url = URI.join(base_url.end_with?("/") ? base_url : "#{base_url}/", "")
    end

    def search(datastore:, query:, start: 0, count: 10, sort: nil, filters: {})
      uid = resolve_uid(datastore)
      body = {
        uid: uid,
        request_id: 1,
        start: start,
        count: count,
        field_tree: {},
        facets: filters,
        settings: {},
        raw_query: query
      }
      body[:sort] = sort if sort
      post_json("/spectrum/#{uid}", body)
    end

    def record(datastore:, id:)
      uid = resolve_uid(datastore)
      get_json("/spectrum/#{uid}/record/#{CGI.escape(id)}")
    end

    def export_ris(datastore:, ids:, base_url: "")
      uid = resolve_uid(datastore)
      body = {
        uid => {
          "records" => ids,
          "base_url" => base_url
        }
      }
      post_text("/spectrum/file", body)
    end

    private

    def resolve_uid(datastore_name)
      self.class.datastores.fetch(datastore_name) do
        raise RequestError, "Unknown datastore: #{datastore_name}"
      end
    end

    def post_json(path, body)
      response = http_post(path, body)
      raise RequestError, "Spectrum returned #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end

    def get_json(path)
      response = http_get(path)
      raise RequestError, "Spectrum returned #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end

    def post_text(path, body)
      response = http_post(path, body)
      raise RequestError, "Spectrum returned #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      response.body
    end

    def http_post(path, body)
      uri = URI.join(@base_url, path)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = body.to_json
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(request) }
    end

    def http_get(path)
      uri = URI.join(@base_url, path)
      request = Net::HTTP::Get.new(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(request) }
    end
  end
end
