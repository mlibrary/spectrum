class Spectrum::Entities::GetThisWorkOrderOption
  def self.for(item, client=AlmaRestClient.client)
    if ['ASIA'].include?(item.location) && item.process_type == "WORK_ORDER_DEPARTMENT"
      response = client.get("/items", query: {item_barcode: item.barcode})
      if response.code == 200
        self.new(response.parsed_response)
      else
        GetThisWorkOrderNotApplicable.new
      end
    else
      GetThisWorkOrderNotApplicable.new
    end
  end
  def initialize(data)
    @data = data
  end
  def not_in_gettable_workorder?
    !in_gettable_workorder?
  end
  def in_gettable_workorder?
    ["AcqWorkOrder","Labeling"].include?(@data.dig("item_data","work_order_type","value"))
  end

  class GetThisWorkOrderNotApplicable < self
    def initialize
    end
    def in_gettable_workorder?
      false
    end
  end

end
