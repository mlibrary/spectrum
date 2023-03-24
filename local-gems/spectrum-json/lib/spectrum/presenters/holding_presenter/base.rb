module Spectrum
  module Presenters
    module HoldingPresenter
      class Base
        def initialize(holding)
          @holding = holding
        end

        def self.for(holding)
          if /Hathi/.match?(holding.class.name.to_s)
            HathiHoldingPresenter.new(holding)
            # elsif holding.up_links || holding.down_links
            # LinkedHoldingPresenter.for(holding)
          elsif holding.library == "ELEC"
            ElectronicHoldingPresenter.new(holding)
          elsif holding.library == "EMPTY"
            EmptyHoldingPresenter.new(holding)
          else
            AlmaHoldingPresenter.new(holding)
          end
        end

        def to_h
          {
            caption: caption,
            captionLink: captionLink,
            name: name,
            notes: notes,
            headings: headings,
            rows: rows,
            type: type
          }.delete_if { |k, v| v.nil? || v.empty? }
        end

        private

        # [TODO:description mrio: I don't know why this is here]
        def name
          nil
        end

        # [TODO:description mrio: I don't know why this is here]
        def type
          raise NotImplementedError
        end

        # This is the header for each of the holding entities.
        def caption
          raise NotImplementedError
        end

        # This is the link information that goes under the caption. Only
        # AlmaHoldingPresenter instances have this
        def captionLink
          nil
        end

        # This goes below the caption and has extra info about the holding. Only
        # exists for AlmaHoldingPresenter
        def notes
          nil
        end

        # The headings that go in the table of items
        def headings
          raise NotImplementedError
        end

        # The rows of items for a given holding
        def rows
          raise NotImplementedError
        end
      end
    end
  end
end

# Will bring this back at some point, but right now it's not being used
# class LinkedHoldingPresenter < HoldingPresenter
# def self.for(input)
# if input.holding.down_links
# DownLinkedHolding.new(input)
# else
# UpLinkedHolding.new(input)
# end
# end

# private
# def headings
# ['Record link']
# end
# def name
# nil
# end

# def process_link(link)
# [
# {
# text: link['link_text'],
# to: {
# record: link['key'],
# datastore: @holding.doc_id,
# }
# }
# ]
# end
# end
# class DownLinkedHolding < LinkedHoldingPresenter
# private
# def caption
# 'Bound with'
# end
# def rows
# @holding.down_links.map { |link| process_link(link) }
# end
# end
# class UpLinkedHolding < LinkedHoldingPresenter
# private
# def caption
# 'Included in'
# end
# def rows
# @holding.up_links.map { |link| process_link(link) }
# end
# end
