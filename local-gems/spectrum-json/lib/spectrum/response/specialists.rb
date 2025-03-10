# frozen_string_literal: true

module Spectrum
  module Response
    def self.SpecialistEngine(config)
      case config['type']
      when 'two-step'
        SpecialistTwoStep
      else
        SpecialistDirect
      end.new(config)
    end

    class EmptyFieldsFieldList
      def by_uid(_uid)
        self
      end

      def query_field
        ''
      end

      def query_params
        {}
      end
    end

    class SpecialistEngine
      attr_reader :config
      def initialize(config)
        @config = config
      end

      def find(_data)
        puts "#{@config.inspect}.find"
      end

      def focus
        @focus ||= Spectrum::Json.foci[config['focus']]
      end

      def source
        @source ||= Spectrum::Json.sources[focus.source]
      end

      def client
        @client ||= source.driver.constantize.connect(url: source.url)
      end

      def fields
        config['fields']
      end

      def rows
        config['rows']
      end

      def term_threshold
        config['term_threshold']
      end

      def extract_fields(specialist)
        {
          name: specialist['title'],
          url: specialist['url'],
          job_title: specialist['job_title'],
          picture: specialist['smfield_picture_url'].first,
          department: specialist['ssfield_user_department'],
          email: specialist['email'].first,
          phone: specialist['ssfield_phone'],
          office: specialist['smfield_user_location'].first.strip.split(/\n/)
        }
      end
    end

    class SpecialistTwoStep < SpecialistEngine
      def focus
        @focus ||= Array(config['focus']).map { |f| Spectrum::Json.foci[f] }
      end

      def source
        @source ||= focus.map { |f| Spectrum::Json.sources[f.source] }
      end

      def client
        @client ||= source.map { |s| s.driver.constantize.connect(url: s.url) }
      end

      def fetch_records(query)
        params = focus.first.solr_params.merge(query).merge(
          rows: rows.first,
          fl: fields.first
        )
        response = nil
        duration = Benchmark.realtime do
          response = client.first.post('select', params: params)
        end
        ActiveSupport::Notifications.instrument(
          "fetch_records.spectrum_specialists",
          duration: duration,
          params: params,
          response: response
        )
        response
      end

      def extract_terms(records)
        records['response']['docs'].map do |doc|
          doc[fields.first]
        end.compact.flatten.each_with_object(Hash.new(0)) do |field, list|
          list[field] += 1
        end.delete_if do |_field, count|
          count < term_threshold
        end.map do |field, count|
          [RSolr.solr_escape(field).gsub(' ', '\ '), count]
        end.to_h
      end

      def fetch_specialists(terms, query)
        bq = []
        terms.each_pair do |term, count|
          bq << "#{fields.last}:(#{term})^#{count}"
        end

        fq = ['+(' + (query[:fq] || []).map do |fq|
          fq.sub(/^#{fields.first}:/, "#{fields.last}:")
        end.select do |fq|
          fq.start_with?("#{fields.last}:")
        end.join(' OR ') + ')'].
          flatten.
          push('+source:drupal-users +status:true').
          reject { |fq| fq == '+()' }

        params = {
          mm: 1,
          q: terms.keys.join(' OR '),
          qf: fields.last,
          pf: fields.last,
          fq: fq,
          bq: bq,
          defType: 'edismax',
          rows: 10,
          fl: '*',
          wt: 'ruby'
        }
        response = nil
        duration = Benchmark.realtime do
          response = client.last.post('select', params: params)
        end
        ActiveSupport::Notifications.instrument(
          "fetch_specialists_2step.spectrum_specialists",
          duration: duration,
          params: params,
          response: response
        )
        response
      end

      def empty_results
        {
          config['keys']['terms'] => {},
          config['keys']['specialists'] => []
        }
      end

      def find(query)
        records = fetch_records(query)
        return empty_results unless records

        terms = extract_terms(records)
        return empty_results if terms.empty?

        specialists = fetch_specialists(terms, query)
        return empty_results unless specialists

        specialists = specialists['response']['docs'].map do |specialist|
          extract_fields(specialist)
        end
        {
          config['keys']['terms'] => terms,
          config['keys']['specialists'] => specialists
        }
      end
    end

    class SpecialistDirect < SpecialistEngine
      def fetch_specialists(query)
        params = {
          mm: 1,
          q: query,
          qf: fields,
          pf: fields,
          bq: bq,
          defType: 'edismax',
          rows: 10,
          fl: 'score,*',
          fq: '+source:drupal-users +status:true',
          wt: 'ruby'
        }
        response = nil
        duration = Benchmark.realtime do
          response = client.last.post('select', params: params)
        end
        ActiveSupport::Notifications.instrument(
          "fetch_specialists_1step.spectrum_specialists",
          duration: duration,
          params: params,
          response: response
        )
        response
      end

      def find(_query)
        {
          config['keys']['terms'] => {},
          config['keys']['specialists'] => []
        }
      end
    end

    class Specialists
      class << self
        attr_reader :config, :logger, :cache
        def configure(file)
          @config = YAML.load(ERB.new(::File.read(file)).result).map do |key, value|
            if key == 'logger'
              @logger = value
              nil
            elsif key == 'cache'
              @cache = value['driver'].constantize.new(value['size'], value['ttl'])
              nil
            else
              [key, ::Spectrum::Response::SpecialistEngine(value)]
            end
          end.compact.to_h
          @cache ||= LruRedux::TTL::ThreadSafe.new(500, 43_200)
        end
      end

      attr_reader :data

      def initialize(args)
        @data = args
      end

      def cache
        self.class.cache
      end

      def logger
        self.class.logger
      end

      def engines
        self.class.config.values
      end

      def spectrum
        return [] if data[:request].instance_eval { @request&.env&.fetch('dlpsInstitutionId', nil)&.include?('Flint') }
        specialist_focus = Spectrum::Json.foci['mirlyn']
        # catalog/mirlyn is on new parser
        # because diff datastores have diff search fields,
        # we re-parse the original search under catalog config
        psearch = data[:request].build_psearch(specialist_focus)
        query = data[:request].new_parser_query(
          specialist_focus.fields,
          specialist_focus.facet_map,
          psearch
        )
        return [] if query[:q] == '*:*'
        begin
          results = engines.map do |engine|
            engine.find(query)
          end.inject({}) do |acc, item|
            acc.merge(item)
          end
          report(
            query: query[:q],
            filters: query[:fq],
            hlb: results['hlb'].keys.map { |term| term.delete('\\') },
            expertise: results['expertise'].keys,
            hlb_expert: results['hlb_expert'].map { |expert| expert[:email].sub(/@umich.edu/, '') },
            expertise_expert: results['expertise_expert']
          )
          merge(results['hlb_expert'] + results['expertise_expert'])
        rescue
          []
        end
      end

      def merge(results)
        results.flatten.compact
      end

      def report(user: '', query: '', filters: [], hlb: [], expertise: [], hlb_expert: [], expertise_expert: [])
        return
        return unless logger
        Thread.new do
          uri = URI(logger)
          req = Net::HTTP::Post.new(uri)
          req.body = {
            user: user,
            query: query,
            filters: filters,
            hlb: hlb,
            expertise: expertise,
            hlb_expert: hlb_expert,
            expertise_expert: expertise_expert
          }.to_query
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            http.request(req)
          end
        end
      end
    end
  end
end
