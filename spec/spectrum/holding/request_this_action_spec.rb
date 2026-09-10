# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../stub_bib_record"

describe Spectrum::Holding::RequestThisAction, ".match" do
  before(:each) do
    @item = instance_double(Spectrum::Entities::AlmaItem, can_reserve?: false)
  end
  subject do
    described_class.match?(@item)
  end
  it "generally does not match if can_reserve? is false" do
    expect(subject).to eq(false)
  end
  it "matches if can_reserve? is true" do
    allow(@item).to receive(:can_reserve?).and_return(true)
    expect(subject).to eq(true)
  end
end
describe Spectrum::Holding::RequestThisAction do
  let(:special_collections_bib_record) {
    methods = [
      :title,
      :author,
      :genre,
      :date,
      :edition,
      :publisher,
      :place,
      :extent,
      :sgenre
    ].map { |x| [x, x] }.to_h
    instance_double(Spectrum::SpecialCollectionsBibRecord, **methods)
  }
  let(:bib_record) {
    methods = [
      :fullrecord,
      :mms_id,
      :genre,
      :sgenre,
      :restriction,
      :edition,
      :physical_description,
      :date,
      :pub,
      :place,
      :publisher,
      :pub_date,
      :author,
      :title,
      :isbn,
      :issn
    ].map { |x| [x, x] }.to_h
    instance_double(Spectrum::BibRecord, **methods)
  }

  let(:solr_item) {
    methods = [:library, :callnumber, :description, :location, :barcode,
      :inventory_number].map { |x| [x, x] }.to_h
    double("BibRecord::AlmaHolding::Item", **methods)
  }

  let(:item) { Spectrum::Entities::AlmaItem.new(holding: nil, alma_loan: {}, bib_record: bib_record, solr_item: solr_item) }

  let(:query_params) {
    ["Action", "Form", "callnumber", "genre", "title", "author", "date", "edition",
      "publisher", "place", "extent", "barcode", "description", "sysnum", "location",
      "sublocation", "fixedshelf", "issn", "isbn", "sgenre"].sort
  }

  subject { described_class.new(item, special_collections_bib_record) }

  context "#finalize" do
    it "returns an N/A cell." do
      expect(subject.finalize[:text]).to eq("Request This")
      href = URI.parse(subject.finalize[:href])
      query = href.query.split("&").map { |x| x.split("=").first }
      expect(query).to eq(query_params)
      expect(href.hostname).to eq("aeon.lib.umich.edu")
    end
  end
  context "Spectrum::Holding::ClementsRequestThisAction" do
    context "#href" do
      it "has a restriction option" do
        allow(bib_record).to receive(:restriction).and_return("restriction")
        clements_action = Spectrum::Holding::ClementsRequestThisAction.new(item, special_collections_bib_record)
        href = URI.parse(clements_action.finalize[:href])
        query = {}
        href.query.split("&").each do |x|
          kv = x.split("=")
          query[kv[0]] = kv[1]
        end
        expect(query["accessrestrict"]).to eq("restriction")
      end
    end
  end
end
