require 'ostruct'

module Keycard
  module Cookie
    class Institution
      attr_reader :name, :key, :value, :access
      def initialize(init)
        @name = init['name']
        @key = init['key']
        @value = init['value']
        @access = init['access'] || 'allow'
      end

      def allow?
        access == 'allow'
      end

      def deny?
        access != 'allow'
      end

      def match(record)
        return self if record[key] == value
        return nil
      end
    end

    class InstitutionFinder
      attr_reader :config

      def initialize(config: 'config/keycard.yml')
        @config = configure(YAML.load_file(config)['cookie'])
      end

      def attributes_for(request)
        return {} unless request.cookies
        return {} if (institutions = match(request.cookies)).empty?
        {config.institution_finder.key => institutions}
      end

      private
      def match(record)
        matches = config.institution_finder.institutions.map { |inst| inst.match(record) }.compact
        denied = matches.select(&:deny?).map(&:name)
        matches.select(&:allow?).map(&:name).reject { |inst| denied.include?(inst) }
      end

      def configure(cfg)
        OpenStruct.new(
          institution_finder: OpenStruct.new(
            key: cfg['institution_finder']['key'] || 'dlpsInstitutionId',
            institutions: cfg['institution_finder']['institutions'].map {|inst| Institution.new(inst) }
          )
        )
      end

    end
  end
end
