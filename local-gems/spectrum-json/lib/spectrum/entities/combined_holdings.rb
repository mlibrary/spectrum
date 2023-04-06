require "ostruct"
module Spectrum::Entities
  class CombinedHoldings
    attr_reader :holdings, :bib_record
    # alma and hathi holdings
    extend Forwardable
    def_delegators :@alma_holdings, :find_item

    # Combined holdings derrived from the bib record.
    # @param alma_holdings [Spectrum::Entities::AlmaHoldings]
    # @param hathi_holding [[Spectrum::Entities::HathiHolding]]
    # @param bib_record [[Spectrum::BibRecord]]
    def initialize(alma_holdings:, hathi_holding:, bib_record:)
      @bib_record = bib_record
      @alma_holdings = alma_holdings
      @hathi_holding = hathi_holding
      @elec_holdings = bib_record.elec_holdings
      @holdings = []

      @holdings.push(OpenStruct.new(library: "ELEC", items: @elec_holdings)) unless @elec_holdings.empty?
      @holdings.push(@hathi_holding) unless @hathi_holding.empty?
      @alma_holdings&.holdings&.each { |h| @holdings.push(h) }
      @holdings.push(Spectrum::EmptyItemHolding.new(@bib_record)) if @holdings.empty?
    end

    def self.for(source, request)
      for_bib(Spectrum::BibRecord.fetch(id: request.id, url: source.url, id_field: request.id_field))
    end

    def self.for_bib(bib_record,
      alma_holdings = Spectrum::Entities::AlmaHoldings.for(bib_record: bib_record),
      hathi_holding = Spectrum::Entities::HathiHolding.new(bib_record))

      Spectrum::Entities::CombinedHoldings.new(alma_holdings: alma_holdings, hathi_holding: hathi_holding, bib_record: bib_record)
    end

    def hathi_holdings
      [@hathi_holding] unless @hathi_holding.empty?
    end

    def [](index)
      @holdings[index]
    end

    def each(&block)
      @holdings.each(&block)
    end

    def empty?
      @holdings.empty?
    end
  end
end
