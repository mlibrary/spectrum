class Spectrum::Entities::AlmaHold
  def self.for(request: )
    self.new(
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
    @client = AlmaRestClient.client
    @response = nil
  end

  def item_hold_url
    "/bibs/#{@doc_id}/holdings/#{@holding_id}/items/#{@item_id}/requests?user_id=#{@patron_id}"
  end

  def title_hold_url
    "/bibs/#{@doc_id}/requests?user_id=#{@patron_id}"
  end

  def title_hold_body
    {
      "request_type" => "HOLD",
      "pickup_location_type" => "LIBRARY",
      "pickup_location_library" => @pickup_location,
      "pickup_location_institution" => "01UMICH_INST",
      "last_interest_date" => @last_interest_date,
    }
  end

  def item_hold_body
    title_hold_body.merge("holding_id" => @holding_id)
  end

  def create!
    @response = @client.post(item_hold_url, body: item_hold_body.to_json)
    # mrio: turning this off. reference ticket: SEARCH-1588
    # If the item level hold fails, try a title level hold
    #if no_items_can_fulfill?
      #@response = @client.post(title_hold_url, body: title_hold_body.to_json)
    #end
    self
  end

  def no_items_can_fulfill?
    error? && [error_code].flatten(1).include?('401129')
  end

  def error_code
    error_fetch('errorCode')
  end

  def error_message
    error_fetch('errorMessage')
  end

  def error_fetch(type)
    return nil unless @response&.parsed_response
    @response.parsed_response.dig('errorList', 'error')&.map {|error| error.dig(type)} ||
      @response.parsed_response.dig('web_service_result', 'errorList', 'error', type)
  end

  def error?
    @response&.code != 200 ||
      @response&.body.nil? ||
      @response&.parsed_response.nil? ||
      @response&.parsed_response&.dig('errorsExist') ||
      @response&.parsed_response&.dig('web_service_result', 'errorsExist')
  end

  def success?
    @response&.code == 200 && @response&.parsed_response&.dig('request_id')
  end
  
end
