module Spectrum
  class EmptyItemHolding
    extend Forwardable
    def_delegators :@bib_record, :mms_id, :doc_id, :etas?, :title, :author,
      :restriction, :edition, :physical_description, :date, :pub, :place,
      :publisher, :pub_date, :issn, :isbn, :genre, :sgenre, :accession_number,
      :finding_aid, :fullrecord, :oclc

    attr_reader :id, :doc_id

    def initialize(bib_record)
      @bib_record = bib_record
    end

    def library
      "EMPTY"
    end

    def barcode
      "unavailable"
    end

    def status
      "In Process"
    end

    def cited_title
      "NoHoldings"
    end

    # Things that respond with the empty string
    [:callnumber, :notes, :issue, :full_item_key, :location, :library_display_name].each do |name|
      define_method(name) do
        ""
      end
    end

    # Things that respond with true
    [:closed_stacks?, :can_request?, :mobile?, :off_shelf?,
      :ann_arbor?, :not_on_shelf?, :not_reservable_library?].each do |name|
      define_method(name) do
        true
      end
    end

    # Things that respond with false
    [:can_book?, :can_reserve?, :circulating?, :on_shelf?, :building_use_only?,
      :missing?, :known_off_shelf?, :open_stacks?, :checked_out?, :reopened?,
      :flint?, :in_labeling?, :in_acq?, :reservable_library?,
      :in_international_studies_acquisitions_technical_services?,
      :recallable?].each do |name|
      define_method(name) do
        false
      end
    end
  end
end
