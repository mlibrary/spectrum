class Spectrum::Entities::GetThisWorkOrderOption
  def self.for(item, client = AlmaRestClient.client)
    if item.process_type == "WORK_ORDER_DEPARTMENT"
      response = client.get("/items", query: {item_barcode: item.barcode})
      raise StandardError if response.status != 200
      new(response.body)
    else
      GetThisWorkOrderNotApplicable.new
    end
  rescue
    GetThisWorkOrderNotApplicable.new
  end

  def initialize(data)
    @data = data
  end

  def in_labeling?
    ["Labeling"].include?(@data.dig("item_data", "work_order_type", "value"))
  end

  def in_getable_acq_work_order?
    in_international_studies_acquisitions_technical_services? || in_asia_backlog?
  end

  def in_international_studies_acquisitions_technical_services?
    ["AcqWorkOrder"].include?(@data.dig("item_data", "work_order_type", "value")) &&
      ["IS-SEEES"].include?(@data.dig("item_data", "location", "value"))
  end

  def in_asia_backlog?
    ["AcqWorkOrder"].include?(@data.dig("item_data", "work_order_type", "value")) &&
      ["ASIA"].include?(@data.dig("item_data", "location", "value"))
  end

  class GetThisWorkOrderNotApplicable < self
    def initialize
    end

    def in_international_studies_acquisitions_technical_services?
      false
    end

    def in_labeling?
      false
    end

    def in_getable_acq_work_order?
      false
    end
  end
end
