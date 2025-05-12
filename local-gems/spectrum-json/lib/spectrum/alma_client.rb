require "alma_rest_client"
class Spectrum::AlmaClient
  AlmaRestClient.configure do |config|
    config.http_adapter = [:httpx, {persistent: false}]
  end
  def self.client
    AlmaRestClient.client
  end
end
