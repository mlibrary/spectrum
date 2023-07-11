# frozen_string_literal: true

require "marc"
require "rsolr"

module Spectrum
  class BibRecord
    attr_reader :fullrecord

    RESERVABLE = Hash.new(false).merge(
      "Video (Blu-ray)" => true,
      "Video (DVD)" => true,
      "Audio CD" => true,
      "Audio LP" => true
    )

    def self.fetch(id:, url:, id_field: "id", rsolr_client_factory: lambda { |url| RSolr.connect(url: url) }, escaped_id: RSolr.solr_escape(id))
      # if someone ever passes in id_field but it is nil, that will be very annoying to diagnose
      # previously the query was hard-coded "id:#{escaped_id}"
      id_field ||= "id"
      client = rsolr_client_factory.call(url)
      # extracting this variable instead of running in the new()
      # makes the difference on my machine between it working and not
      # I don't know why and I don't like that I don't know why
      client_get = client.get("select", params: {q: "#{id_field}:#{escaped_id}"})
      BibRecord.new(client_get)
    end

    def initialize(solr_response)
      @data = extract_data(solr_response) || {}
      full_record_raw = @data["fullrecord"]
      if full_record_raw
        @fullrecord = MARC::XMLReader.new(StringIO.new(full_record_raw)).first
      else
        @full_record = {}
      end
    end

    def mms_id
      @data["id"]
    end

    def doc_id
      mms_id
    end

    def title
      (@fullrecord["245"] || []).select do |subfield|
        /[abdefgknp]/ === subfield.code
      end.map(&:value).join(" ")
    end

    def restriction
      (@fullrecord["506"] || []).select do |subfield|
        /[abc]/ === subfield.code
      end.map(&:value).join(" ")
    end

    def callnumber
      fetch_first("callnumber")
    end

    def issn
      candidate = fetch_first("issn")
      if candidate.empty? && fetch_first("isbn").empty?
        "N/A"
      else
        candidate
      end
    end

    def isbn
      fetch_first("isbn")
    end

    def edition
      fetch_first("edition")
    end

    def author
      fetch_joined("mainauthor", "; ")
    end

    def accession_number
      "<accession_number>#{oclc}</accession_number>"
    end

    def oclc
      fetch_joined("oclc", ",")
    end

    def date
      fetch_marc("260", "c")
    end

    def pub
      fetch_marc("260", "b")
    end

    def place
      fetch_marc("260", "a")
    end

    def pub_date
      fetch_marc("245", "f")
    end

    def publisher
      (@fullrecord["260"] || []).select do |subfield|
        /[abc]/ === subfield.code
      end.map(&:value).join(" ")
    end

    def physical_description
      clean_marc((@fullrecord["300"] || []).select do |subfield|
        /[abcf]/ === subfield.code
      end.map(&:value).join(" "))
    end

    def genre
      {
        "BK" => "Book",
        "SE" => "Serial Publication",
        "MP" => "Map",
        "MU" => "Music",
        "VM" => "Visual Material",
        "MV" => "Mixed Material`",
        "MX" => "Mixed Material"
      }[fmt]
    end

    def sgenre
      {
        "BK" => "Book",
        "SE" => "Book",
        "MP" => "Map",
        "MU" => "Graphics",
        "VM" => "Graphics",
        "MV" => "Manuscripts",
        "MX" => "Manuscripts"
      }[fmt]
    end

    def fmt
      (@fullrecord["970"] || {"a" => ""})["a"]
    end

    def physical_only?
      @fullrecord.fields("856").map { |field| field["u"] }.compact.empty?
    end

    def holdings
      if @data["hol"]
        JSON.parse(@data["hol"])&.map { |x| Holding.for(x) }
      else
        []
      end
    end

    def hathi_holding
      holdings.find { |x| x.class.name.to_s.match(/HathiHolding/) }
    end

    def alma_holdings
      holdings.select { |x| x.class.name.to_s.match(/AlmaHolding/) }
    end

    def alma_holding(holding_id)
      holdings.find { |x| x.holding_id == holding_id }
    end

    # non-HathiTrust Electronic Holdings or Digital Holdings
    def elec_holdings
      holdings.select { |x| ["ELEC", "ALMA_DIGITAL"].any? { |y| x.library == y } }
    end

    def physical_holdings?
      alma_holdings.any?
    end

    def etas?
      !!hathi_holding&.etas?
    end

    def finding_aid
      holdings&.find { |x| x.finding_aid == true }
    end

    def not_etas?
      !etas?
    end

    def reservable_format?
      formats.any? { |format| RESERVABLE[format] }
    end

    class Holding
      def initialize(holding)
        @holding = holding
      end

      def holding_id
        ""
      end

      def finding_aid
        false
      end

      def library
        @holding["library"]
      end

      def self.for(holding)
        [HathiHolding, FindingAid, ElectronicHolding, DigitalHolding, AlmaHolding].find do |klass|
          klass.match?(holding)
        end.new(holding)
      end
    end

    # passes through the data from a Digital Holding
    class DigitalHolding < Holding
      def self.match?(holding)
        holding["library"] == "ALMA_DIGITAL"
      end
      ["public_note", "link", "link_text", "delivery_description", "label"].each do |name|
        define_method(name) do
          @holding[name]
        end
      end
    end

    class ElectronicHolding < Holding
      def self.match?(holding)
        holding["library"] == "ELEC"
      end
      ["status", "description", "link_text", "note", "finding_aid"].each do |name|
        define_method(name) do
          @holding[name]
        end
      end

      # Alma's community zone electronic holdings all route through the Alma link resolver.
      # Which in turn routes through the proxy server traffic cop, which is good.
      # Regular records, with the url in the 856, however, do not, which leaves
      # people out of the proxy server.  So add a campus-agnostic proxy prefix.
      def link
        return @holding["link"] if @holding["link"]&.include?("alma.exlibrisgroup")
        "https://apps.lib.umich.edu/proxy-login/?url=#{@holding["link"]}"
      end
    end

    class FindingAid < ElectronicHolding
      def self.match?(holding)
        holding["finding_aid"] == true
      end
    end

    class HathiHolding < Holding
      def self.match?(holding)
        holding["library"] == "HathiTrust Digital Library"
      end

      def etas?
        items.any? { |x| x.status.start_with?("Full text available,") }
      end

      def items
        @holding["items"].map { |x| Item.new(x) }
      end

      class Item
        def initialize(item)
          @item = item
        end
        ["id", "rights", "description", "collection_code",
          "access", "source", "status"].each do |name|
          define_method(name) do
            @item[name]
          end
        end
        # def access
        # !!@item["access"]
        # end
      end
      private_constant :Item
    end

    class AlmaHolding < Holding
      def self.match?(holding)
        true
      end

      def holding_id
        @holding["hol_mmsid"]
      end
      ["location", "callnumber", "public_note", "summary_holdings", "display_name",
        "floor_location", "info_link"].each do |name|
        define_method(name) do
          @holding[name].to_s&.strip
        end
      end
      def items
        @holding["items"].map { |x| Item.new(x) }
      end

      class Item
        def initialize(item)
          @item = item
        end

        def id
          @item["item_id"]
        end
        ["description", "public_note", "barcode", "library", "location",
          "permanent_library", "permanent_location", "process_type",
          "callnumber", "item_policy", "inventory_number", "item_id",
          "fulfillment_unit", "location_type", "record_has_finding_aid",
          "material_type"].each do |name|
          define_method(name) do
            @item[name]
          end
        end
        def can_reserve?
          @item["can_reserve"]
        end

        def temp_location?
          @item["temp_location"]
        end

        def item_location_text
          @item["display_name"]
        end

        def item_location_link
          @item["info_link"]
        end
      end

      private_constant :Item
    end

    private_constant :Holding, :AlmaHolding

    private

    def fetch_marc(datafield, subfield)
      clean_marc(((@fullrecord || {})[datafield] || {})[subfield] || "")
    end

    def extract_data(solr_response)
      solr_response["response"]["docs"].first
    end

    def fetch_first(key)
      fetch_list(key).first || ""
    end

    def fetch_joined(key, string = ", ")
      fetch_list(key).join(string)
    end

    def fetch_list(key)
      Array(@data[key])
    end

    def clean_marc(str)
      str.respond_to?(:sub) ? str.sub(/[.,;:\/]$/, "") : ""
    end

    def formats
      @data&.fetch("format", []) || []
    end
  end
end
