require "alma_rest_client"
require "faraday/follow_redirects"
class Spectrum::AlmaClient
  AlmaRestClient.configure do |config|
    config.http_adapter = [:httpx, {persistent: false}]
  end
  def self.client
    conn = Faraday.new do |faraday|
      faraday.response :follow_redirects
    end
    AlmaRestClient::Client.new(conn)
  end
end
