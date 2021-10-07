# frozen_string_literal: true
module Spectrum
  module Config
    class Metadata
      attr_accessor :name, :short_desc
      def initialize(args = {})
        if args.respond_to? :[]
          @name = args['name']
          @short_desc = args['short_desc']
        else
          @name = args.name
          @short_desc = args.short_desc
        end
      end

      def spectrum
        { name: @name, short_desc: @short_desc }
      end
    end
  end
end
