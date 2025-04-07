require "alma_rest_client"
class Spectrum::AlmaClient
  def self.client(httparty_on: false)
    new(httparty_on: httparty_on)
  end
  attr_reader :client
  def initialize(httparty_on: false)
    @client = AlmaRestClient.client
    @httparty_on = httparty_on
  end

  def get(path, kwargs = {})
    response = @client.get(path, **kwargs)
    process_response(response)
  end

  def post(path, kwargs = {})
    response = @client.post(path, **kwargs)
    process_response(response)
  end

  def get_all(kwargs)
    response = @client.get_all(**kwargs)
    process_response(response)
  end

  def process_response(response)
    if @httparty_on && ["Faraday::Response", "AlmaRestClient::Response"].include?(response.class.to_s)
      httparty_response(response)
    else
      response
    end
  end

  def httparty_response(response)
    OpenStruct.new(code: response.status, parsed_response: response.body, body: response.body)
  end
end
