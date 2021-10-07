# frozen_string_literal: true

module Spectrum
  module Json
    module Schema
      NUMBER  = { 'type' => 'number' }.freeze
      OBJECT  = { 'type' => 'object' }.freeze
      STRING  = { 'type' => 'string' }.freeze
      BOOLEAN = { 'type' => 'boolean' }.freeze
      INTEGER = { 'type' => 'integer' }.freeze

      SCALAR = { 'anyOf' => [STRING, NUMBER, BOOLEAN] }.freeze

      FIELD_TREE = {
        'type' => 'object',
        'id' => 'field_tree',
        'properties' => {
          'type' => STRING,
          'value' => STRING,
          'children' => {
            'type' => 'array',
            'items' => {
              '$ref' => 'field_tree'
            }
          }
        }
      }.freeze

      REQUEST = {
        'type' => 'object',
        'properties' => {
          'uid' => STRING,
          'request_id' => SCALAR,
          'start' => INTEGER,
          'count' => INTEGER,
          'field_tree' => FIELD_TREE,
          'facets' => OBJECT,
          'settings' => OBJECT
        }
      }.freeze

      FACET_REQUEST = REQUEST.merge({})

      def self.validate(type, data)
        JSON::Validator.validate(schema(type), data)
      end

      def self.validate!(type, data)
        JSON::Validator.validate!(schema(type), data)
      end

      private

      def self.schema(type)
        case type
        when :request then REQUEST
        when :facet_request then FACET_REQUEST
        end
      end
    end
  end
end
