# frozen_string_literal: true
module Spectrum
  module Config
    class FormattedPageRangeField < Field
      type 'formatted_page_range'

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
        start_page = @fields['start_page'].value(data)
        end_page = @fields['end_page'].value(data)

        if start_page
          if end_page && start_page != end_page
            "#{start_page} - #{end_page}"
          else
            start_page
          end
        else
          if end_page
            end_page
          end
        end
      end
    end
  end
end
