module Spectrum
  class AvailableOnlineHolding
    attr_reader :id, :doc_id

    def initialize(id)
      @id = id
      @doc_id = id
    end

    def barcode
      id
    end

    # Things that respond with Available Online
    [:location, :status].each do |name|
      define_method(name) do
        'Available Online'
      end
    end


    # Things that respond with the empty string
    [:callnumber, :notes, :issue, :full_item_key].each do |name|
      define_method(name) do
        ''
      end
    end

    # Things that respond with true
    [:off_site?, :circulating?, :can_request?, :mobile?, :off_shelf?].each do |name|
      define_method(name) do
        true
      end
    end

    # Things that respond with false
    [:can_book?, :can_reserve?, :circulating?, :on_shelf?,
     :building_use_only?, :missing?, :known_off_shelf?,
     :on_site?, :checked_out?, :reopened?].each do |name|
       define_method(name) do
         false
       end
    end
  end
end
