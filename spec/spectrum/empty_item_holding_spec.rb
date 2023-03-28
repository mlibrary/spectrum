describe Spectrum::EmptyItemHolding do
  subject do
    # this record has holdings, but an EmptyItemHolding will ignore them. The
    # bib_record is only used for info about the bib
    bib_record = Spectrum::BibRecord.new(JSON.parse(File.read("./spec/fixtures/solr_bib_alma.json")))
    described_class.new(bib_record)
  end
  context "barcode" do
    it "returns \"None\"" do
      expect(subject.barcode).to eq("None")
    end
  end
  context "#status" do
    it "returns \"In Process\"" do
      expect(subject.status).to eq("In Process")
    end
  end
  # This is so document delivery can know that this is an item without displayed
  # holdings
  context "#cited_title" do
    it "returns \"NoHoldings\"" do
      expect(subject.cited_title).to eq("NoHoldings")
    end
  end
  [:callnumber, :notes, :issue, :full_item_key, :location, :library_display_name].each do |method|
    context "##{method}" do
      it "returns an empty string" do
        expect(subject.send(method)).to eq("")
      end
    end
  end
  [:off_site?, :can_request?, :mobile?, :off_shelf?, :ann_arbor?,
    :not_on_shelf?, :not_reservable_library?].each do |method|
    context "##{method}" do
      it "returns true" do
        expect(subject.send(method)).to eq(true)
      end
    end
  end
  [:can_book?, :can_reserve?, :circulating?, :on_shelf?, :building_use_only?,
    :missing?, :known_off_shelf?, :on_site?, :checked_out?, :reopened?,
    :open_stacks?, :flint?, :in_labeling?, :in_acq?, :reservable_library?,
    :in_international_studies_acquisitions_technical_services?,
    :recallable?].each do |method|
    context "##{method}" do
      it "returns false" do
        expect(subject.send(method)).to eq(false)
      end
    end
  end
  [:mms_id, :doc_id, :etas?, :title, :author, :restriction, :edition,
    :physical_description, :date, :pub, :place, :publisher, :pub_date, :issn,
    :isbn, :genre, :sgenre, :accession_number, :finding_aid, :fullrecord, :oclc].each do |method|
    context "##{method}" do
      it "has a response" do
        expect(subject).to respond_to(method)
      end
    end
  end
end
