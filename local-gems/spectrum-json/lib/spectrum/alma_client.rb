require "alma_rest_client"
class Spectrum::AlmaClient
  def self.client
    AlmaRestClient.client
  end
end
