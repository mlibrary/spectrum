require "alma_rest_client"
class Spectrum::AlmaClient
  def self.client(http_party_on: false)
    new(http_party_on: http_party_on)
  end
  attr_reader :client
  def initialize(http_party_on: false)
    @client = AlmaRestClient.client
  end

  def get(path, kwargs = {})
    @client.get(path, **kwargs)
  end

  def post(path, kwargs = {})
    @client.post(path, **kwargs)
  end

  def get_all(kwargs)
    @client.get_all(**kwargs)
  end
end
