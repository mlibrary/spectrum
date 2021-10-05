# frozen_string_literal: true
module Spectrum
  module Config
    class BookplateField < Field
      type 'bookplate'

      attr_reader :bookplates

      def initialize_from_instance(i)
        super
        @bookplates = i.bookplates
      end

      def initialize_from_hash(args, config)
        super
        @bookplates = config.bookplates
      end

      def value(data, request = nil)
        return nil unless data[@field].respond_to?(:each)
        data[@field].each do |fund|
          if @bookplates[fund]
            return [
              {
                'uid' => 'desc',
                'name' => 'Description',
                'value' => @bookplates[fund].desc,
                'value_has_html' => false
              },
              {
                'uid' => 'image',
                'name' => 'Image',
                'value' => @bookplates[fund].image,
                'value_has_html' => false
              }
            ]
          end
        end
      end
    end
  end
end
