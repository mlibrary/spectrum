module Spectrum::Decorators
  class MirlynItemDecorator < SimpleDelegator
    #provides methods for determining material access

    REOPENED = [
      'HATCH',
      'HSRS',
      'BUHR',
      'SHAP',
      'SCI',
      'UGL',
      'FINE',
      'AAEL',
      'MUSIC',
      'RMC',
      'OFFS',
      'STATE',
      'MUSM',
      'HERB',
    ]

    SHAPIRO_AND_AAEL_PICKUP = [
      'OFFS',
      'ELLS',
      'STATE',
    ]

    SHAPIRO_PICKUP = [
      'HATCH',
      'SHAP',
      'SCI',
      'UGL',
      'FINE',
      'BUHR',
      'HSRS',
      'RMC',
      'MUSM',
      'HERB',
      #'OFFS',  # This is in SHAPIRO_AND_AAEL
      #'STATE', # This is in SHAPIRO_AND_AAEL
    ]

    AAEL_PICKUP = [ 'AAEL' ]

    MUSIC_PICKUP = [ 'MUSIC' ]

    FLINT_PICKUP = [ 'FLINT' ]

    ETAS_START = 'Full text available,'

    attr_reader :hathi_holding
    def initialize(item, hathi_holdings = [])
      @item = item
      __setobj__ @item
      @hathi_holdings = hathi_holdings
    end

    def self.for(source, request, 
      get_holdings=lambda {|source, request| Spectrum::Entities::Holdings.for(source,request) } 
                )

      return Spectrum::AvailableOnlineHolding.new(request.id) if request.barcode == 'available-online'
      holdings = get_holdings.call(source, request)
      item = holdings.find_item(request.barcode)
      hathi_holdings = holdings.hathi_holdings
      Spectrum::Decorators::MirlynItemDecorator.new(item, hathi_holdings)
    end

    def etas?
      etas_items.values.include?(true)
    end
    def not_etas?
      !etas?
    end

    def music_pickup?
      MUSIC_PICKUP.include?(@item.sub_library)
    end

    def aael_pickup?
      AAEL_PICKUP.include?(@item.sub_library)
    end

    def shapiro_pickup?
      SHAPIRO_PICKUP.include?(@item.sub_library)
    end
    def shapiro_and_aael_pickup?
      SHAPIRO_AND_AAEL_PICKUP.include?(@item.sub_library)
    end
    def flint_pickup?
      FLINT_PICKUP.include?(@item.sub_library)
    end
    def flint?
      @item.sub_library == 'FLINT'
    end
    def not_flint?
      !flint?
    end
    def reopened?
      REOPENED.include?(@item.sub_library)
    end
    def standard_pickup?
      flint_pickup?
    end
    def not_pickup?
      !(shapiro_pickup? || aael_pickup? || music_pickup? || shapiro_and_aael_pickup? || flint_pickup?)
    end
    def checked_out?
      @item.status.start_with?('Checked out') ||
        @item.status.start_with?('Recalled') ||
        @item.status.start_with?('Requested') ||
        @item.status.start_with?('Extended loan')
    end
    def not_checked_out?
      !checked_out?
    end
    def missing?
      @item.status.start_with?('missing')
    end
    def not_missing?
      !missing?
    end
    def on_order?
      @item.status.start_with?('On Order')
    end
    def not_on_order?
      !on_order?
    end
    def building_use_only?
      @item.status.start_with?('Building use only')
    end
    def not_pickup_or_checkout?
      not_pickup? || checked_out? || missing? || building_use_only?
    end
    def can_request?
      @item.can_request? ||
        ['HSRS', 'HERB', 'MUSM'].include?(@item.sub_library)
    end
    #as of 27-April-2021 none of these are used in get_this_policy
    def circulating?
      can_request?
    end
    def on_shelf?
      @item.status.start_with?('On shelf') || building_use_only?
    end
    def off_site?
      @item.location.start_with?('Offsite', '- Offsite')
    end
    def on_site?
      !off_site?
    end
    private
    def etas_items
      @hathi_holdings.map{|x| x.items}
        .flatten
        .map{ |item| [item.id, item.status.start_with?(ETAS_START)] }
        .to_h
    end
  end
end
