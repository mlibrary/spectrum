class Spectrum::Entities::GetThisOption
  attr_reader :label, :description, :tip, :faq, :grants, :weight, :orientation
  def initialize(option:, patron:, item:, now:)
    @now = now
    @option = option
    @patron = patron
    @item = item

    @weight = option["weight"] || 0
    @description = option["description"]
    @faq = option["faq"]
    @label = option["label"]
    @orientation = option["orientation"] || ""
    @tip = option["tip"]
  end

  def self.for(option:, patron:, item:, now: DateTime.now)
    args = {option: option, patron: patron, item: item, now: now}
    case option.dig("form", "type")
    when "reservation"
      Spectrum::Entities::GetThisOption::Reservation.new(**args)
    when "link"
      Spectrum::Entities::GetThisOption::Link.new(**args)
    when "alma_hold"
      Spectrum::Entities::GetThisOption::AlmaHold.new(**args)
    when "alma_recall"
      Spectrum::Entities::GetThisOption::AlmaRecall.new(**args)
    when "illiad_request"
      Spectrum::Entities::GetThisOption::ILLiadRequest.new(**args)
    else
      Spectrum::Entities::GetThisOption.new(**args)
    end
  end

  def form
    {
      "action" => "",
      "fields" => [],
      "method" => "post"
    }
  end

  def to_h
    {
      description: @description,
      faq: @faq,
      form: form,
      label: @label,
      orientation: @orientation,
      tip: @tip
    }.stringify_keys
  end

  class Reservation < self
    def form
      {
        "action" => @option.dig("form", "base") + @item.barcode,
        "method" => "get",
        "fields" => [
          {
            "type" => "submit",
            "value" => @option.dig("form", "text")
          }
        ]
      }
    end
  end

  class Link < self
    def form
      {
        "action" => @option.dig("form", "href"),
        "method" => "get",
        "fields" => [
          {
            "type" => "submit",
            "value" => @option.dig("form", "text")
          }
        ]
      }
    end
  end

  class AlmaHold < self
    def form
      {
        "type" => "ajax",
        "method" => "post",
        "action" => "/spectrum/mirlyn/hold",
        "fields" => [
          {
            "type" => "hidden",
            "name" => "record",
            "value" => @item.mms_id
          },
          {
            "type" => "hidden",
            "name" => "item",
            "value" => "#{@item.holding_id}/#{@item.item_id}"
          },
          {
            "type" => "select",
            "label" => "Pickup location",
            "name" => "pickup_location",
            "value" => "select-a-pickup-location",
            "options" => select_options
          },
          {
            "type" => "date",
            "label" => "Cancel this hold if item is not available before",
            "name" => "not_needed_after",
            "value" => not_needed_after
          },
          {
            "type" => "submit",
            "name" => "submit",
            "value" => submit_text
          }
        ]
      }
    end

    private

    def submit_text
      "Get me this item"
    end

    def select_options
      output = [
        {
          "disabled" => true,
          "name" => "Select a pickup location",
          "value" => "select-a-pickup-location"
        }
      ]
      @option.dig("form", "pickup_locations").each do |code|
        output.push({
          "value" => code,
          "name" => Spectrum::Entities::LocationLabels.get_this(code)
        })
      end
      output
    end

    def not_needed_after
      if @item.in_acq?
        # one year from now
        @now.next_year.strftime("%Y-%m-%d")
      else
        # two months from now
        (@now >> 2).strftime("%Y-%m-%d")
      end
    end
  end

  class AlmaRecall < AlmaHold
    private

    def submit_text
      "Recall this item"
    end
  end

  class ILLiadRequest < self
    def form
      output = base_form
      output["fields"].concat(additional_fields)
      output
    end

    private

    def additional_fields
      @option.dig("form", "fields").map do |x|
        {"type" => "hidden"}.merge(x)
      end
    end

    def base_form
      {
        "method" => "get",
        "action" => "https://ill.lib.umich.edu/illiad/illiad.dll",
        "fields" =>
        [
          {"type" => "hidden",
           "name" => "action",
           "value" => "10"},
          {"type" => "hidden",
           "name" => "form",
           "value" => "30"},
          {"type" => "hidden",
           "name" => "sid",
           "value" => "mirlyn"},
          {"type" => "hidden",
           "name" => "rft_dat",
           "value" => @item.oclc},
          {"type" => "hidden",
           "name" => "isbn",
           "value" => @item.isbn},
          {"type" => "hidden",
           "name" => "title",
           "value" => @item.title},
          {"type" => "hidden",
           "name" => "rft.au",
           "value" => @item.author},
          {"type" => "hidden",
           "name" => "date",
           "value" => @item.date},
          {"type" => "hidden",
           "name" => "rft.pub",
           "value" => @item.pub},
          {"type" => "hidden",
           "name" => "rft.place",
           "value" => @item.place},
          {"type" => "hidden",
           "name" => "callnumber",
           "value" => @item.callnumber},
          {"type" => "hidden",
           "name" => "rft.edition",
           "value" => @item.edition}, # is this in item
          {"type" => "hidden",
           "name" => "rft.issue",
           "value" => ""},
          {"type" => "hidden",
           "name" => "aleph_location",
           "value" => @item.library_display_name},
          {"type" => "hidden",
           "name" => "aleph_item_status",
           "value" => ""},
          # this only exists for Spectrum::EmptyItemHolding
          {
            "type" => "hidden",
            "name" => "CitedTitle",
            "value" => @item.cited_title
          },
          {"type" => "hidden",
           "name" => "barcode",
           "value" => @item.barcode},
          {"type" => "submit",
           "value" => "Place a request"}
        ]
      }
    end
  end
end
