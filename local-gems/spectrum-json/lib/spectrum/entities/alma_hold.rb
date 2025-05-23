class Spectrum::Entities::AlmaHold
  def self.for(request:)
    new(
      doc_id: request.record_id,
      holding_id: request.holding_id,
      item_id: request.item_id,
      patron_id: request.patron_id,
      pickup_location: request.pickup_location,
      last_interest_date: request.not_needed_after
    )
  end

  def initialize(doc_id:, holding_id:, item_id:, patron_id:, pickup_location:, last_interest_date:)
    @doc_id = doc_id
    @holding_id = holding_id
    @item_id = item_id
    @patron_id = patron_id
    @pickup_location = pickup_location
    @last_interest_date = last_interest_date
    @client = Spectrum::AlmaClient.client
    @response = nil
  end

  def item_hold_url
    "/bibs/#{@doc_id}/holdings/#{@holding_id}/items/#{@item_id}/requests?user_id=#{@patron_id}"
  end

  def item_hold_body
    {
      "request_type" => "HOLD",
      "pickup_location_type" => "LIBRARY",
      "pickup_location_library" => @pickup_location,
      "pickup_location_institution" => "01UMICH_INST",
      "last_interest_date" => @last_interest_date
    }
  end

  def create!
    @response = @client.post(item_hold_url, body: item_hold_body.to_json)
    self
  end

  def error_code
    error_fetch("errorCode")
  end

  def error_message
    error_fetch("errorMessage")
  end

  def error_fetch(type)
    return nil unless @response&.body
    @response.body.dig("errorList", "error")&.map { |error| error.dig(type) } ||
      @response.body.dig("web_service_result", "errorList", "error", type)
  end

  def error?
    @response&.status != 200 ||
      @response&.body.nil? ||
      !@response&.body&.dig("errorsExist").nil? ||
      !@response&.body&.dig("web_service_result", "errorsExist").nil?
  end

  def success?
    @response&.status == 200 && !@response&.body&.dig("request_id").nil?
  end
end
