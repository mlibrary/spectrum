require 'net/ldap'
require 'ostruct'
require 'lru_redux'

module Keycard
  module Ldap
    class Institution
      attr_reader :name, :attribute, :method, :value, :access
      def initialize(init)
        @name = init['name']
        @attribute = init['attribute']
        @method = init['method']
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
        if method == 'intersect'
          return self unless (value & record[attribute]).empty?
        end
        return nil
      end
    end

    class InstitutionFinder
      ConnectionConfig = Struct.new(:host, :port, :encryption, :method, :username, :password)

      attr_reader :config, :connection, :cache

      def initialize(config: 'config/keycard.yml')
        @config = configure(YAML.load_file(config)['ldap'])

        #initialize cache and ldap connection.
        @cache      = init_cache
        @connection = connect
      end

      def attributes_for(request)
        return {} unless (username = request.env['HTTP_X_REMOTE_USER'])
        return {} if username.empty?
        return {} unless (record = search(username))
        return {} if (institutions = match(record)).empty?
        {config.institution_finder.key => institutions}
      end

      private
      def match(record)
        matches = config.institution_finder.institutions.map { |inst| inst.match(record) }.compact
        denied = matches.select(&:deny?).map(&:name)
        matches.select(&:allow?).map(&:name).reject { |inst| denied.include?(inst) }
      end

      def init_cache
        config.cache.driver.new(config.cache.size, config.cache.ttl)
      end

      def base
        config.institution_finder.base
      end

      def filter(username)
        config.institution_finder.filter % username
      end

      def search(username)
        return nil unless username
        cache.getset(username) do
          record = connection.search(base: base, filter: filter(username)).first
        end
      end

      def configure(cfg)
        OpenStruct.new(
          cache: OpenStruct.new(
            driver: cfg['cache']['driver'].constantize,
            size: cfg['cache']['size'],
            ttl: cfg['cache']['ttl']
          ),
          connection: ConnectionConfig.new(
            cfg['connection']['host'],
            cfg['connection']['port'],
            cfg['connection']['encryption'].to_sym,
            cfg['connection']['method'].to_sym,
            cfg['connection']['username'],
            cfg['connection']['password']
          ),
          institution_finder: OpenStruct.new(
            key: cfg['institution_finder']['key'] || 'dlpsInstitutionId',
            filter: cfg['institution_finder']['filter'],
            base: cfg['institution_finder']['base'],
            institutions: cfg['institution_finder']['institutions'].map {|inst| Institution.new(inst) }
          )
        )
      end

      def connect
        Net::LDAP.new(
          host: config.connection.host,
          port: config.connection.port,
          encryption: config.connection.encryption,
          auth: {
            method: config.connection.method,
            username: config.connection.username,
            password: config.connection.password
          }
        ).tap { |connection| connection.bind }
      end
    end
  end
end
