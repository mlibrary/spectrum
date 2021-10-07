class Spectrum::Holding::PhysicalItemStatus
  attr_reader :text
  def initialize(text)
    @text = text
  end
  ['intent', 'icon'].each do |name|
    define_method(name) {}
  end
  def to_h
    {
      text: @text,
      intent: intent,
      icon: icon
    }
  end
  def self.for(item)
    case item.process_type
    when nil
      if item.in_unavailable_temporary_location?
        Error.new('Unavailable')
      else
        Success.new(Text::AvailableText.for(item).to_s)
      end
    when 'LOAN'
       
      return Warning.new(Text::CheckedOutText.new(item).to_s) 
      #if item.due_date.nil? || item.due_date.empty?
      ##string format "Sep 01, 2021" or 
      ##"Sep 01, 2021 at 3:00 PM"
        
        #date = DateTime.parse(item.due_date)
        #date_string = "Checked out: due #{date.strftime("%b %d, %Y")}"

        #if ['06', '07', '11', '12'].include?(item.item_policy)
          #date_string = date_string + ' at' + date.strftime("%l:%M %p")
        #end

        #Warning.new(date_string)
    when 'MISSING'
      Error.new('Missing')
    when 'ILL'
      Error.new('Unavailable - Ask at ILL')
      
    else
      Warning.new("In Process: #{item.process_type}")
    end
  end
  class Success < self
    def intent
      'success'
    end
    def icon
      'check_circle'
    end
    def base_text
      "On shelf"
    end
  end
  class Warning < self
    def intent
      'warning'
    end
    def icon
      'warning'
    end
  end
  class Error < self
    def intent
      'error'
    end
    def icon
      'error'
    end
  end
end
