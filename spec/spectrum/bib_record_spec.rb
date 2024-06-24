# frozen_string_literal: true

require_relative "../rails_helper"

describe Spectrum::BibRecord do
  before(:each) do
    @solr_bib_alma = File.read("./spec/fixtures/solr_bib_alma.json")
  end
  subject do
    described_class.new(JSON.parse(@solr_bib_alma))
  end

  context "#mms_id" do
    it "returns a string" do
      expect(subject.mms_id).to eq("990020578280106381")
    end
  end
  # needs to have bib Holdings.
  context "#holdings" do
    it "returns an array" do
      expect(subject.holdings.class.name).to eq("Array")
    end
    context "alma holding" do
      let(:alma_holding) { subject.holdings.first }
      it "has a library" do
        expect(alma_holding.library).to eq("HATCH")
      end
      it "has a location" do
        expect(alma_holding.location).to eq("GRAD")
      end
      it "has a callnumber" do
        expect(alma_holding.callnumber).to eq("LB 2331.72 .S371 1990")
      end
      it "has a public_note" do
        expect(alma_holding.public_note).to eq("")
      end
      it "has items" do
        expect(alma_holding.items.count).to eq(1)
      end
      it "has a display_name" do
        expect(alma_holding.display_name).to eq("Hatcher Graduate")
      end
      it "has a floor_location" do
        expect(alma_holding.floor_location).to eq("6 South")
      end
      it "has an info_link" do
        expect(alma_holding.info_link).to eq("https://lib.umich.edu/locations-and-hours/hatcher-library")
      end
    end

    context "#alma_holdings" do
      it "returns alma holdings when there are any" do
        expect(subject.alma_holdings.count).to eq(1)
      end
    end
    context "#elec_holdings" do
      it "returns empty array when no non-hathi electronic holdings" do
        expect(subject.elec_holdings).to eq([])
      end
    end
    context "#finding_aid" do
      it "returns nil when no holding with a finding aid" do
        expect(subject.finding_aid).to be_nil
      end
    end

    context "#alma_holding(holding_id)" do
      it "returns the alma holding for a given holding id" do
        expect(subject.alma_holding("22957681780006381").callnumber).to eq("LB 2331.72 .S371 1990")
      end
      it "returns nil for no matching holding" do
        expect(subject.alma_holding("not_a_holding_id")).to be_nil
      end
    end
    context "an alma holding" do
      let(:alma_holding) { subject.holdings[0] }
      ["holding_id", "location", "callnumber", "public_note", "items", "summary_holdings"].each do |method|
        context "##{method}" do
          it "respond_to? #{method}" do
            expect(alma_holding.respond_to?(method)).to be(true)
          end
        end
      end
    end
    context "an alma item" do
      let(:alma_item) { subject.holdings[0].items[0] }
      ["library", "location", "description", "public_note", "barcode",
        "item_policy", "process_type", "permanent_location", "permanent_library",
        "id", "temp_location?", "callnumber", "inventory_number", "item_id",
        "fulfillment_unit", "location_type", "record_has_finding_aid"].each do |method|
        context "##{method}" do
          it "respond_to? #{method}" do
            expect(alma_item.respond_to?(method)).to be(true)
          end
        end
      end
      context "#can_reserve?" do
        it "returns a boolean" do
          expect(alma_item.can_reserve?).to eq(false)
        end
      end
      context "#item_location_text" do
        it "returns a string" do
          expect(alma_item.item_location_text).to eq("Hatcher Graduate")
        end
      end
      context "#item_location_link" do
        it "returns a string" do
          expect(alma_item.item_location_link).to eq("https://lib.umich.edu/locations-and-hours/hatcher-library")
        end
      end
    end
    context "#physical_holdings?" do
      it "returns true for if there are physical holdings" do
        expect(subject.physical_holdings?).to eq(true)
      end
      it "returns false for only holdings with library ELEC" do
        @solr_bib_alma = @solr_bib_alma.gsub("HATCH", "ELEC")
        expect(subject.physical_holdings?).to eq(false)
      end
    end
    context "#hathi_holding" do
      it "returns a HathiHolding item" do
        expect(subject.hathi_holding.class.name.to_s).to eq("Spectrum::BibRecord::HathiHolding")
      end
      it "returns nil for no Hathi Item" do
        @solr_bib_alma = @solr_bib_alma.gsub("HathiTrust", "SomeOtherTrust")
        expect(subject.hathi_holding).to be_nil
      end
    end
    context "hathi holding" do
      let(:hathi_holding) { subject.holdings[1] }
      it "has a library" do
        expect(hathi_holding.library).to eq("HathiTrust Digital Library")
      end
      it "has items" do
        expect(hathi_holding.items.count).to eq(1)
      end
      context "hathi item" do
        let(:hathi_item) { hathi_holding.items[0] }

        it "has an id" do
          expect(hathi_item.id).to eq("mdp.39015017893416")
        end
        it "has rights" do
          expect(hathi_item.rights).to eq("ic")
        end
        it "has a description" do
          expect(hathi_item.description).to eq("")
        end
        it "has a collection_code" do
          expect(hathi_item.collection_code).to eq("MIU")
        end
        it "has access boolean" do
          expect(hathi_item.access).to eq(false)
        end
        it "has a source" do
          expect(hathi_item.source).to eq("University of Michigan")
        end
        it "has a status" do
          expect(hathi_item.status).to eq("Search only (no full text)")
        end
      end
    end
    context "bib record with ELEC holdings" do
      before(:each) do
        @solr_elec = File.read("./spec/fixtures/solr_elec.json")
      end
      subject do
        described_class.new(JSON.parse(@solr_elec))
      end
      it "has holdings" do
        expect(subject.holdings.count).to eq(1)
      end
      it "does not have physical holdings" do
        expect(subject.physical_holdings?).to eq(false)
      end
      context "#elec_holdings" do
        it "returns electronic holdings for library ELEC" do
          expect(subject.elec_holdings.count).to eq(1)
        end
        it "returns electronic holdings for library ALMA_DIGITAL" do
          @solr_elec = @solr_elec.gsub('library\":\"ELEC\"', 'library\":\"ALMA_DIGITAL\"')
          expect(subject.elec_holdings.count).to eq(1)
        end
      end
      context "finding_aid" do
        it "returns nil when finding_aid is false" do
          expect(subject.finding_aid).to be_nil
        end
        it "returns nil when no finding aid" do
          @solr_elec = @solr_elec.gsub('finding_aid\\":false,', "")
          expect(subject.finding_aid).to be_nil
        end
        it "returns holding when there is a finding_aid" do
          @solr_elec = @solr_elec.gsub('finding_aid\\":false', "finding_aid\\\":true")
          expect(subject.finding_aid.class.name).to include("FindingAid")
        end
      end
      context "electronic holding" do
        let(:elec_holding) { subject.holdings.first }
        ["link", "library", "status", "link_text", "note", "description", "finding_aid"].each do |method|
          context "##{method}" do
            it "respond_to? #{method}" do
              expect(elec_holding.respond_to?(method)).to be(true)
            end
          end
        end
        it "actually returns the right thing for an element" do
          expect(elec_holding.status).to eq("Available")
        end
      end
    end
  end
  context "#title" do
    it "returns a string" do
      expect(subject.title).to eq("Enhancing faculty careers : strategies for development and renewal /")
    end
  end

  context "#issn" do
    it "returns a string" do
      expect(subject.issn).to eq("")
    end
  end

  context "#isbn" do
    it "returns a string" do
      expect(subject.isbn).to eq("9781555422103")
    end
  end

  context "#bib.accession_number" do
    it "returns a string" do
      expect(subject.accession_number).to eq("<accession_number>20758549</accession_number>")
    end
  end

  context "#author" do
    it "returns a string" do
      expect(subject.author).to eq("Schuster, Jack H.")
    end
  end

  context "#date" do
    it "returns a string from 260" do
      expect(subject.date).to eq("1990")
    end
    it "returns a string from 264" do
      @solr_bib_alma = File.read("spec/fixtures/solr_bib_on_order_with_264.json")
      expect(subject.date).to eq("2024")
    end
  end

  context "#pub" do
    it "returns a string" do
      expect(subject.pub).to eq("Jossey-Bass Publishers")
    end
  end

  context "#place" do
    it "returns a string" do
      expect(subject.place).to eq("San Francisco ")
    end
  end

  context "#edition" do
    it "returns a string" do
      expect(subject.edition).to eq("1st ed.")
    end
  end

  context "#callnumber" do
    it "returns a string" do
      expect(subject.callnumber).to eq("LB 2331.72 .S371 1990")
    end
  end
  context "#restriction" do
    it "returns a string" do
      expect(subject.restriction).to eq("")
    end
  end
  context "#pub_date" do
    it "returns a string" do
      expect(subject.pub_date).to eq("")
    end
  end
  context "#publisher" do
    it "returns a string" do
      expect(subject.publisher).to eq("San Francisco : Jossey-Bass Publishers, 1990.")
    end
  end
  context "#physical_description" do
    it "returns a string" do
      expect(subject.physical_description).to eq("xxiv, 346 p. : ill. ; 24 cm")
    end
  end
  context "#genre" do
    it "returns a string" do
      expect(subject.genre).to be_nil
    end
  end
  context "#sgenre" do
    it "returns a string or nil" do
      expect(subject.sgenre).to be_nil
    end
  end
  context "#fmt" do
    it "returns a string" do
      expect(subject.fmt).to eq("")
    end
  end
  context "#physical_only?" do
    it "returns a boolean" do
      expect(subject.physical_only?).to eq(true)
    end
  end
end

describe Spectrum::BibRecord::ElectronicHolding do
  context "#link" do
    subject { described_class.new({"link" => url}) }

    context "When the holding has an Alma link" do
      let(:url) { "https://na04.alma.exlibrisgroup.com" }

      it "Returns the Alma link unchanged" do
        expect(subject.link).to eq(url)
      end
    end

    context "When the holding has an non-Alma link" do
      let(:url) { "https://www.lib.umich.edu" }
      let(:proxied_url) { "https://apps.lib.umich.edu/proxy-login/?qurl=#{URI.encode_www_form_component(url)}" }

      it "Returns the proxied link" do
        expect(subject.link).to eq(proxied_url)
      end
    end
  end
end
