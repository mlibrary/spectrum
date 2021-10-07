# frozen_string_literal: true
module Spectrum
  module Config
    class Href
      attr_accessor :field, :prefix

      UID = 'href'
      NAME = 'HREF'
      HAS_HTML = false
      DEFAULT_FIELD = 'id'
      DEFAULT_PREFIX = ''

      def initialize(args = {})
        args ||= {}
        @field  = args['field'] || DEFAULT_FIELD
        @prefix = args['prefix'] || DEFAULT_PREFIX
      end

      def apply(data, base_url)
        {
          uid: UID,
          name: NAME,
          value: get_url(data, base_url),
          value_has_html: HAS_HTML
        }
      end

      def apply_object(data, base_url)
        value = data.send(@field.to_sym)

        value = data.send(DEFAULT_FIELD.to_sym) if value.nil?

        apply_value(value, base_url)
      end

      def apply_hash(data, base_url)
        value = data[@field]

        value = data[DEFAULT_FIELD] if value.nil?
        apply_value(value, base_url)
      end

      def apply_value(value, base_url)
        if value.nil?
          value = ''
        elsif value === Array
          value = value.join('/')
        end

        "#{base_url}/#{@prefix}/record/#{value}"
      end

      def get_url(data, base_url)
        if data.respond_to? :[]
          apply_hash(data, base_url)
        else
          apply_object(data, base_url)
        end
      end
    end
  end
end
