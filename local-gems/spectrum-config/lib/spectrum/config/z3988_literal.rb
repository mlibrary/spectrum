require 'uri'

module Spectrum
  module Config
    class Z3988Literal
      attr_accessor :id, :namespace

      def initialize(args)
        self.id = args['id'] if args
        self.namespace = args['namespace'] || '' if args
      end

      def value(data)
        if id && data && data[:value]
          [data[:value]].flatten.map do |val|
            "#{URI::encode_www_form_component(id)}=#{URI::encode_www_form_component(namespace.to_s + val.to_s)}"
          end
        else
          [ ]
        end
      end
    end
  end
end
