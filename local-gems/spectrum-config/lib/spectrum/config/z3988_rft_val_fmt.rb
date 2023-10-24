require 'uri'

module Spectrum
  module Config
    class Z3988RftValFmt
      attr_accessor :id, :namespace

      JOURNAL = "info:ofi/fmt:kev:mtx:journal"
      BOOK = "info:ofi/fmt:kev:mtx:book"
      DISSERTATION = "info:ofi/fmt:kev:mtx:dissertation"
      PATENT = "info:ofi/fmt:kev:mtx:patent"

      JOURNAL_FORMATS = ['journal', 'serial']
      DISSERTATION_FORMATS = ['thesis', 'dissertation']
      PATENT_FORMATS = ['patent']

      def initialize(args)
        self.id = (args || {})['id'] || 'rft_val_fmt'
        self.namespace = (args || {})['namespace'] || ''
      end

      def value(data)
        val = if id && data && data[:value]
          formats = [data[:value]].flatten.map(&:downcase)
          if JOURNAL_FORMATS.any? { |fmt| formats.include?(fmt) }
            JOURNAL
          elsif DISSERTATION_FORMATS.any? { |fmt| formats.include?(fmt) }
            DISSERTATION
          elsif PATENT_FORMATS.any? { |fmt| formats.include?(fmt) }
            PATENT
          else
            BOOK
          end
        else
          BOOK
        end
        ["#{URI::encode_www_form_component(id)}=#{URI::encode_www_form_component(namespace.to_s + val.to_s)}"]
      end
    end
  end
end
