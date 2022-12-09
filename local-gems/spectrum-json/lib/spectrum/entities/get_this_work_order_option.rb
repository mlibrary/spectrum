class Spectrum::Entities::GetThisWorkOrderOption
  def self.for(item, client=AlmaRestClient.client)
    if item.process_type == "WORK_ORDER_DEPARTMENT"
      response = client.get("/items", query: {item_barcode: item.barcode})
      raise StandardError if response.code != 200
      self.new(response.parsed_response)
    else
      GetThisWorkOrderNotApplicable.new
    end
  rescue
      GetThisWorkOrderNotApplicable.new
  end
  def initialize(data)
    @data = data
  end
  def not_in_gettable_workorder?
    !in_gettable_workorder?
  end
  def in_gettable_workorder?
    in_labeling? || in_international_studies_acquitions_techenical_services?
  end

  def in_labeling?
    ["Labeling"].include?(@data.dig("item_data","work_order_type","value"))
  end

  def in_international_studies_acquitions_techenical_services?
    ["AcqWorkOrder"].include?(@data.dig("item_data","work_order_type","value")) && 
    ["IS-SEEES"].include?(@data.dig("item_data","location","value"))
  end
  

  class GetThisWorkOrderNotApplicable < self
    def initialize
    end
    def in_gettable_workorder?
      false
    end
  end

end
