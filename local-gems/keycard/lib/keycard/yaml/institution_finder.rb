# frozen_string_literal: true

require 'yaml'
require 'keycard/yaml/institution'

module Keycard
  module Yaml
    # looks up institution ID(s) by IP address
    class InstitutionFinder
      attr_reader :config

      def initialize(yaml: 'config/keycard.yml')
        @config = load_config(YAML.load_file(yaml)['yaml']['institution_finder'])
      end

      def attributes_for(request)
        return {} unless (numeric_ip = numeric_remote_ip(request))
        return {} if (insts = insts_for_ip(numeric_ip)).empty?
        { key => insts }
      end

      private

      def key
        config['key']
      end

      def institutions
        config['institutions']
      end

      def load_config(config_hash)
        config_hash.tap do |cfg|
          cfg['key'] ||= 'dlpsInstitutionId'
          cfg['institutions'].map! { |row| Institution.new(row) }
        end
      end

      def match(numeric_ip)
        institutions.map { |inst| inst.match?(numeric_ip) }.compact
      end

      def insts_for_ip(numeric_ip)
        return [] if (matching = match(numeric_ip)).empty?
        denied = matching.reject(&:allow?).map(&:name)
        matching.reject(&:deny?).map(&:name).reject { |name| denied.include?(name) }
      end

      def numeric_remote_ip(request)
        Institution.parse_ip(request.respond_to?(:remote_ip) ? request.remote_ip : request.ip)
      end
    end
  end
end
