module Spectrum
  class Presenters::PhysicalItem
    def initialize(item)
      @item = item #Entities::MirlynItem
    end
    def to_a(action: Spectrum::Holding::Action.for(@item),
             status: Spectrum::Holding::PhysicalItemStatus.for(@item)
             )
      [
        action.finalize,
        {
          text: @item.description || "" 
        },
        {
          text: status.text || 'N/A',
          intent: status.intent || 'N/A',
          icon: status.icon || 'N/A'
        },
        { text: call_number || 'N/A' }
      ]
    end
    private 
    def call_number
      return nil unless (callnumber = @item.callnumber)
      return callnumber unless (inventory_number = @item.inventory_number)
      return callnumber unless callnumber.start_with?('VIDEO')
      [callnumber, inventory_number].join(' - ')
    end
  end
end
