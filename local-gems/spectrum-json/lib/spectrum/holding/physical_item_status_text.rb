class Spectrum::Holding::PhysicalItemStatus::Text
  def initialize(item)
    @item = item
  end
  def to_s
    ''
  end
  class AvailableText < self
    def self.for(item)
      if item.in_reserves?
        AvailableReservesText.new(item)
      elsif item.temp_location?
        AvailableTemporaryLocationText.new(item)
      elsif item.library == "SHAP" && item.location == "GAME"
        AvailableGameText.new
      else
        AvailableText.new(item)
      end
    end
    def to_s
      [base_text, suffix].reject{|x| x.nil?}.join(' ')
    end
    private
    def base_text
      if @item.fulfillment_unit == "Limited" || @item.item_policy == '08'
        "Building use only"
      else
        "On shelf"
      end
    end
    def suffix
      case @item.item_policy
      when '06'
        "(4-hour loan)"
      when '07'
        "(2-hour loan)"
      when "1 Day Loan"
        "(1-day loan)"
      end
    end
  end
  class AvailableGameText
    def to_s
      "CVGA room use only; check out required"
    end
  end
  class AvailableTemporaryLocationText < AvailableText
    def base_text
      output = "Temporary location: #{@item.item_location_text}"
      if super != 'On shelf'
        [output, super].join('; ')
      else
        output
      end
    end
  end
  class AvailableReservesText < AvailableText
    def base_text
      "On reserve at #{@item.item_location_text}"
    end
  end
  class CheckedOutText < self
    def to_s 
      [base_text, temp_location].reject{|x| x.nil?}.join(' ')
    end
    private
    def base_text
      return "Checked out" if @item.due_date.nil? || @item.due_date.empty?
      date = DateTime.parse(@item.due_date)
      date_string = "Checked out: due #{date.strftime("%b %d, %Y")}"

      if ['06', '07'].include?(@item.item_policy)
        date_string = date_string + ' at' + date.strftime("%l:%M %p")
      end
      date_string 
    end
    def temp_location
      if @item.in_reserves?
        "On reserve at #{@item.item_location_text}"
      end
    end
  end
end
