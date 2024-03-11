require 'uri'

module Spectrum
  module Config
    class Z3988RftValFmt
      attr_accessor :id, :namespace

      JOURNAL = "info:ofi/fmt:kev:mtx:journal"
      BOOK = "info:ofi/fmt:kev:mtx:book"
      JOURNAL_FORMATS = ['Journal', 'Serial']

      def initialize(args)
        self.id = args['id'] || 'rft_val_fmt' if args
        self.namespace = args['namespace'] || '' if args
      end

      def value(data)
        val = if id && data && data[:value]
          formats = [data[:value]].flatten
          if JOURNAL_FORMATS.any? { |fmt| formats.include?(fmt) }
            JOURNAL
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
