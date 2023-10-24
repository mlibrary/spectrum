require 'uri'

module Spectrum
  module Config
    class Z3988RftGenre
      attr_accessor :id, :namespace

      JOURNAL = "journal"
      BOOK = "book"
      PATENT = 'patent'
      DISSERTATION = 'thesis'
      DOCUMENT = 'document'
      CONFERENCE = 'conference'

      JOURNAL_FORMATS = ['journal', 'serial']
      BOOK_FORMATS = ['book', 'ebook', 'biography', 'dictionaries', 'encyclopedias']
      PATENT_FORMATS = ['patent']
      DISSERTATION_FORMATS = ['dissertation', 'thesis']
      CONFERENCE_FORMATS = ['conference']

      def initialize(args)
        self.id = (args || {})['id'] || 'rft.genre'
        self.namespace = (args || {})['namespace'] || ''
      end

      def value(data)
        val = if id && data && data[:value]
          formats = [data[:value]].flatten.map(&:downcase)
          if JOURNAL_FORMATS.any? { |fmt| formats.include?(fmt) }
            JOURNAL
          elsif BOOK_FORMATS.any? { |fmt| formats.include?(fmt) }
            BOOK
          elsif PATENT_FORMATS.any? { |fmt| formats.include?(fmt) }
            PATENT
          elsif DISSERTATION_FORMATS.any? { |fmt| formats.include?(fmt) }
            DISSERTATION
          elsif CONFERENCE_FORMATS.any? { |fmt| formats.include?(fmt) }
            CONFERENCE
          else
            DOCUMENT
          end
        else
          DOCUMENT
        end
        ["#{URI::encode_www_form_component(id)}=#{URI::encode_www_form_component(namespace.to_s + val.to_s)}"]
      end
    end
  end
end
