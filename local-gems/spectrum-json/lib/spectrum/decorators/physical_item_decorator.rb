module Spectrum::Decorators
  class PhysicalItemDecorator < SimpleDelegator
    # provides methods for determining material access

    SCANNABLE_MATERIAL_TYPES = [
      "BOOK",
      "ISSUE",
      "FILM",
      "FICHE",
      "ISSBD",
      "MIXED",
      "OVERSIZE",
      "PHDTHESIS",
      "MICROFORM"
    ]

    REOPENED = [
      "HATCH",
      "HSRS",
      "BUHR",
      "SHAP",
      "SCI",
      "UGL",
      "FINE",
      "AAEL",
      "MUSIC",
      "RMC",
      "OFFS",
      "STATE",
      "MUSM",
      "HERB"
    ]

    SHAPIRO_AND_AAEL_PICKUP = [
      "OFFS",
      "ELLS",
      "STATE"
    ]

    SHAPIRO_PICKUP = [
      "HATCH",
      "SHAP",
      "SCI",
      "UGL",
      "FINE",
      "BUHR",
      "HSRS",
      "RMC",
      "MUSM",
      "HERB"
      # 'OFFS',  # This is in SHAPIRO_AND_AAEL
      # 'STATE', # This is in SHAPIRO_AND_AAEL
    ]

    AAEL_PICKUP = ["AAEL"]

    MUSIC_PICKUP = ["MUSIC"]

    FLINT_PICKUP = ["FLINT"]

    ETAS_START = "Full text available,"

    extend Forwardable

    def_delegators :@work_order_option, :in_labeling?

    attr_reader :hathi_holding
    def initialize(item, hathi_holdings = [], work_order_option = Spectrum::Entities::GetThisWorkOrderOption.for(item))
      @item = item
      __setobj__ @item
      @hathi_holdings = hathi_holdings
      @work_order_option = work_order_option
    end

    # mrio: 2024-06 Document Delivery wants alma_location to return the
    # location code and the library display name.
    # Example: GRAD Hatcher Graduate
    def location_for_illiad
      [@item.permanent_location, @item.library_display_name].compact.join(" ")
    end

    # mrio: 2022-09 per request from Dave in CVGA that items in SHAP Game
    #      are only "Find it in the Library"; Media Fullfillment Unit is
    #      pretty inconsistent so we can't use that
    def game?
      in_game?
    end

    def can_scan?
      SCANNABLE_MATERIAL_TYPES.include?(@item.material_type)
    end

    def not_game?
      !game?
    end

    def not_etas?
      !etas?
    end

    def in_slower_pickup?
      @work_order_option.in_getable_acq_work_order? || in_asia_transit?
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
      @item.library == "FLINT"
    end

    def ann_arbor?
      not_flint?
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
      @item.due_date == "" || @item.due_date.nil?
    end

    def missing?
      @item.process_type == "MISSING"
    end

    def not_missing?
      !missing?
    end

    # Items with a process type include itesm on loan, missing, in acquisition, ILL, lost, etc.
    def not_in_process?
      @item.process_type.nil?
    end

    def in_process?
      !not_in_process?
    end

    def in_acq?
      @item.process_type == "ACQ"
    end

    def not_in_acq?
      !in_acq?
    end

    def not_in_labeling?
      !in_labeling?
    end

    def in_asia_transit?
      @item.library == "HATCH" && @item.location == "ASIA" && @item.process_type == "TRANSIT"
    end

    def building_use_only?
      @item.fulfillment_unit == "Limited" || @item.item_policy == "08" # 08 for Special Collections is also Reading Room Only
    end

    def not_building_use_only?
      !building_use_only?
    end

    def short_loan?
      ["06", "07", "1 Day Loan"].include?(@item.item_policy)
    end

    def not_short_loan?
      !short_loan?
    end

    def not_pickup_or_checkout?
      not_pickup? || checked_out? || missing? || building_use_only?
    end

    def can_request?
      Spectrum::Holding::Action.for(@item).class.to_s.match?(/GetThisAction/)
    end

    def cited_title
      ""
    end

    def circulating?
      can_request?
    end

    def on_shelf?
      !not_on_shelf?
    end

    def closed_stacks?
      ["CLOSED", "NOT_LIB", "REMOTE", "UNAVAIL"].include?(@item.location_type) || @item.fulfillment_unit == "Closed Stacks"
    end

    def open_stacks?
      !closed_stacks?
    end

    def in_resource_sharing_library?
      @item.library == "RES_SHARE"
    end

    def not_on_shelf?
      in_process? || in_reserves?
    end

    def recallable?
      ["LOAN", "HOLDSHELF"].include?(@item.process_type) && not_in_reserves?
    end
  end
end
