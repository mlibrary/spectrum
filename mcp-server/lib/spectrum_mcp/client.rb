require "net/http"
require "json"
require "uri"
require "cgi"

module SpectrumMcp
  # HTTP client for the subset of the Spectrum Sinatra API this MCP server wraps.
  class Client
    class RequestError < StandardError; end

    # Fallback used only if the live /spectrum endpoint can't be reached at load time.
    DEFAULT_FOCI = %w[mirlyn databases onlinejournals primo website].freeze

    def self.foci(base_url: ENV.fetch("SPECTRUM_BASE_URL", "http://localhost:3000"))
      @foci ||= begin
        data = new(base_url: base_url).send(:get_json, "/spectrum")
        data.fetch("response").map { |datastore| datastore.fetch("uid") }
      rescue => e
        warn "spectrum-mcp: falling back to default foci list (#{e.message})"
        DEFAULT_FOCI
      end
    end

    def initialize(base_url: ENV.fetch("SPECTRUM_BASE_URL", "http://localhost:3000"))
      @base_url = URI.join(base_url.end_with?("/") ? base_url : "#{base_url}/", "")
    end

    def search(focus:, query:, start: 0, count: 10, sort: nil)
      body = {
        uid: focus,
        request_id: 1,
        start: start,
        count: count,
        field_tree: {},
        facets: {},
        settings: {},
        raw_query: query
      }
      body[:sort] = sort if sort
      post_json("/spectrum/#{focus}", body)
    end

    def record(focus:, id:)
      get_json("/spectrum/#{focus}/record/#{CGI.escape(id)}")
    end

    def export_ris(focus:, ids:, base_url: "")
      body = {
        focus => {
          "records" => ids,
          "base_url" => base_url
        }
      }
      post_text("/spectrum/file", body)
    end

    private

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
