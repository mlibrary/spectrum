module Spectrum::Decorators
  class PhysicalItemDecorator < SimpleDelegator
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

    def not_etas?
      !etas?
    end

    def music_pickup?
      MUSIC_PICKUP.include?(@item.library)
    end

    def aael_pickup?
      AAEL_PICKUP.include?(@item.library)
    end

    def shapiro_pickup?
      SHAPIRO_PICKUP.include?(@item.library)
    end
    def shapiro_and_aael_pickup?
      SHAPIRO_AND_AAEL_PICKUP.include?(@item.library)
    end
    def flint_pickup?
      FLINT_PICKUP.include?(@item.library)
    end

    def flint?
      @item.library == 'FLINT'
    end

    def ann_arbor?
      @item.library != 'FLINT'
    end

    def not_flint?
      !flint?
    end

    def reopened?
      REOPENED.include?(@item.library)
    end

    def standard_pickup?
      flint_pickup?
    end

    def not_pickup?
      !(shapiro_pickup? || aael_pickup? || music_pickup? || shapiro_and_aael_pickup? || flint_pickup?)
    end

    def checked_out?
      !not_checked_out?
    end
    def not_checked_out?
      @item.due_date == '' || @item.due_date.nil?
    end
    def missing?
      @item.process_type == 'MISSING'
    end
    def not_missing?
      !missing?
    end
    #Items with a process type include itesm on loan, missing, in acquisition, ILL, lost, etc.
    def not_in_process?
      @item.process_type.nil?
    end
    def in_process?
      !not_in_process?
    end
    def on_order?
      @item.process_type == 'ACQ'
    end
    def not_on_order?
      !on_order?
    end
    def building_use_only?
      @item.item_policy == '08' #08 for Special Collections is also Reading Room Only
    end
    def not_building_use_only?
      !building_use_only?
    end
    def not_pickup_or_checkout?
      not_pickup? || checked_out? || missing? || building_use_only?
    end
    def can_request?
      Spectrum::Holding::Action.for(@item).class.to_s.match?(/GetThisAction/) 
    end

    def circulating?
      can_request?
    end
    def on_shelf?
      !not_on_shelf?
    end

    # Deprecated.  I think the semantics people care about now is open/closed stacks.
    def off_site?
      @item.library_display_name.start_with?('Offsite', '- Offsite')
    end

    # Deprecated.  I think the semantics people care about now is open/closed stacks.
    def on_site?
      !off_site?
    end

    def closed_stacks?
      @item.library_display_name.start_with?('Offsite', '- Offsite', 'Buhr')
    end

    def open_stacks?
      !closed_stacks?
    end

    def in_resource_sharing_library?
      @item.library == 'RES_SHARE'
    end

    def not_on_shelf?
      in_process? || in_reserves? 
    end

    def recallable?
      ['LOAN','HOLDSHELF'].include?(@item.process_type) && not_in_reserves?
    end

  end
end
