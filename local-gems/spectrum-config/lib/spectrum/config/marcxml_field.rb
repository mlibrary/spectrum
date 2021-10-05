# frozen_string_literal: true
module Spectrum
  module Config
    class MarcXMLField < Field
      type 'marcxml'

      attr_reader :marc

      def initialize_from_instance(i)
        super
        @marc = i.marc
        @sortable = false
      end

      def initialize_from_hash(args, config)
        super
        @marc = Marc.new(args['marc'])
        @searchable = args['query_field'].nil? ? false : true
        @sortable = false
      end

      def value(data, request = nil)
        record = data[@field + '_parsed'] ||= MARC::XMLReader.new(StringIO.new(super)).first
        marc.aggregate(record)
      end
    end
  end
end
