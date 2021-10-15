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
      else
        AvailableText.new(item)
      end
    end
    def to_s
      if @item.item_policy == '08'
        if ['SPEC','BENT','CLEM'].include?(@item.library)
          "Reading Room Use Only"
        else
          "Building use only"
        end
      else
        [base_text, suffix].reject{|x| x.nil?}.join(' ')
      end
    end
    private
    def base_text
      "On shelf"
    end
    def suffix
      case @item.item_policy
      when '06'
        "(4 Hour Loan)"
      when '07'
        "(2 Hour Loan)"
      when '11'
        "(6 Hour Loan)"
      when '12'
        "(12 Hour Loan)"
      end
    end
  end
  class AvailableTemporaryLocationText < AvailableText
    def base_text
      "Temporary location: #{@item.item_location_text}"
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

      if ['06', '07', '11', '12'].include?(@item.item_policy)
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
