# frozen_string_literal: true
module Spectrum
  module Config
    class SummonAccessUrlField < Field
      type 'summon_access_url'

      attr_reader :model_field, :openurl_root, :openurl_field, :direct_link_field

      def initialize_from_instance(i)
        super
        @model_field = i.model_field
        @openurl_root = i.openurl_root
        @openurl_field = i.openurl_field
        @direct_link_field = i.direct_link_field
      end

      def initialize_from_hash(args, config)
        super
        @model_field = args['model_field']
        @openurl_root = args['openurl_root']
        @openurl_field = args['openurl_field']
        @direct_link_field = args['direct_link_field']
      end

      def value(data, request = nil)
        return nil unless data
        return nil if data.respond_to?(:empty?) && data.empty?

        link_model = [data.src[@model_field]].flatten(1).first
        if link_model == 'OpenURL'
          @openurl_root + '?' + data.send(@openurl_field)
        else
          data.send(@direct_link_field)
        end
      end
    end
  end
end
