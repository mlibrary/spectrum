module Spectrum
  module Config
    class HoldingsResourceAccessField < Field
      type 'holdings_resource_access'

      attr_reader :caption, :headings, :caption_link, :notes, :name, :link_text

      def initialize_from_instance(i)
        super
        @name = i.name
        @notes = i.notes
        @headings = i.headings
        @caption = i.caption
        @caption_link = i.caption_link
        @link_text = i.link_text
      end

      def initialize_from_hash(args, config = {})
        super
        @name = args['name']
        @notes = args['notes']
        @headings = args['headings']
        @caption = args['caption']
        @caption_link = args['caption_link']
        @link_text = args['link_text']
      end

      def value(data, request = nil)
        bib_record = Spectrum::BibRecord.new({'response' => {'docs' => [data]}})

        extra_headings = []

        rows = bib_record.elec_holdings.map do |holding|
          [
            {href: holding.link, text: link_text || holding.link_text},
            {text: [holding.description, holding.note].compact.join(' - ')}
          ]
        end

        return nil if rows.nil? || rows.empty?
        {
          caption: caption,
          headings: headings + extra_headings,
          captionLink: caption_link,
          notes: notes,
          name: name,
          rows: rows,
          preExpanded: true,
          type: 'electronic',
        }.delete_if { |k,v| v.nil? }
      end
    end
  end
end
