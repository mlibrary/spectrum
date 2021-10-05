# frozen_string_literal: true
module Spectrum
  module Config
    class FormattedFullTitleField < Field
      type 'formatted_full_title'

      attr_reader :fields
      def initialize_from_instance(i)
        super
        @fields = i.fields
      end

      def initialize_from_hash(args, config)
        super
        @fields = {}
        args['fields'].each_pair do |fname, fdef|
          @fields[fname] = Field.new(
            fdef.merge('id' => SecureRandom.uuid, 'metadata' => {}),
            config
          )
        end
      end

      def value(data, request = nil)
        @fields['title'].value(data).map do |row|
          kv = row.each_with_object({}) { |i, acc| acc[i[:uid]] = Array(i[:value]).join(' '); }
          [kv['first'], kv['last']].compact.join(': ')
        end
      end
    end
  end
end
