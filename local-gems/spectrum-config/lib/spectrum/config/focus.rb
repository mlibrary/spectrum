# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class Focus
      attr_accessor :id, :name, :weight, :title, :source,
                    :placeholder, :warning, :description,
                    :category, :base,
                    :fields, :url, :filters, :sorts, :id_field, :solr_params,
                    :highly_recommended, :base_url, :raw_config, :default_sort


      HREF_DATA = {
        'id' => 'href',
        'metadata' => {
          'name' => 'HREF',
          'short_desc' => 'The link to the thing in the native interface'
        }
      }.freeze

      def fvf(values)
        values.data.each_with_object([]) do |kv, acc|
          k, v = kv
          @facets.values.each do |facet|
            next if facet.type == 'range'
            next unless facet.uid == k
            [v].flatten(1).each do |val|
              acc << "#{facet.field},#{summon_escape(val)}"
            end
          end
        end
      end

      def rf(values)
        values.data.each_with_object([]) do |kv, acc|
          k, v = kv
          @facets.values.each do |facet|
            next if facet.type != 'range'
            next unless facet.uid == k
            Array(v).each do |val|
              val.match(/^before\s*(\d+)$/) do |m|
                val = "0000:#{m[1]}"
              end
              val.match(/^after\s*(\d+)$/) do |m|
                val = "#{m[1]}:3000"
              end
              val.match(/^(\d+)\s*to\s*(\d+)$/) do |m|
                val = "#{m[1]}:#{m[2]}"
              end
              val.match(/^\d+$/) do |_m|
                val = "#{val}:#{val}"
              end
              acc << "#{@facets[k].field},#{val}"
            end
          end
        end
      end

      def rff(values)
        @facets.values.map { |facet| facet.rff(values) }.compact
      end

      def filter_facets(facets)
        return facets unless facets
        allowed_facet_uids = @facets.values.find_all(&:true_facet?).map(&:uid)
        facets.select { |key, _| allowed_facet_uids.include?(key) }
      end

      def names(fields)
        %w(names title).each do |name|
          fields.each do |field|
            return field[:value] if field[:uid] == name
          end
        end
        []
      end

      def facet(name, _ = nil)
        @facets.facet(name, @facet_values, base_url)
      end

      def facet_url
        @url + '/facet'
      end

      def initialize(args, config)
        @raw_config      = args
        @id              = args['id']
        @base_url        = config.base_url
        @path            = args['path'] || args['id']
        @source          = args['source']
        @weight          = args['weight'] || 0
        @url             = @id == @source ? @id : @source + '/' + @id
        @id_field        = args['id_field'] || 'id'
        @metadata        = Spectrum::Config::Metadata.new(args['metadata'])
        @href            = Spectrum::Config::Href.new('prefix' => @url, 'field' => @id_field)
        @has_holdings    = args['has_holdings']
        @holdings        = Spectrum::Config::HoldingsURL.new('prefix' => @url, 'field' => @id_field)
        @has_get_this    = args['has_get_this']
        @get_this        = Spectrum::Config::GetThisURL.new('prefix' => @url, 'field' => @id_field)
        @sorts           = Spectrum::Config::SortList.new(args['sorts'], config.sorts)
        @fields          = Spectrum::Config::FieldList.new(args['fields'], config.fields)
        @facets          = Spectrum::Config::FacetList.new(args['facets'], config.fields, config.sorts, facet_url)
        @default_sort    = @sorts[args['default_sort']] || @sorts.default
        @solr_params     = args['solr_params'] || {}

        @filters         = args['filters'] || []

        @max_per_page    = args['max_per_page'] || 50_000
        @default_facets  = args['default_facets'] || {}
        @get_null_facets = nil
        @hierarchy       = Hierarchy.new(args['hierarchy']) if args['hierarchy']
        @new_parser      = args['new_parser']
        @highly_recommended = HighlyRecommended.new(args['highly_recommended'])
        @facet_values    = {}
      end

      def new_parser?
        @new_parser
      end

      def default_facets
        @default_facets.dup
      end

      def facet_map
        @facets.reverse_map
      end

      def prefix
        @id + '/'
      end

      def get_id(data)
        value(data, @id_field)
      end

      def get_url(data, _ = nil)
        @href.get_url(data, base_url)
      end

      def datastore_field(_data)
        {
          uid: 'datastore',
          name: 'Datastore',
          value: id,
          value_has_html: false
        }
      end

      def href_field(data, _ = nil)
        @href.apply(data, base_url)
      end

      def holdings_field(data, _ = nil)
        @holdings.apply(data, base_url)
      end

      def get_this_field(data, _ = nil)
        @get_this.apply(data, base_url)
      end

      def has_holdings?
        @has_holdings
      end

      def has_get_this?
        @has_get_this
      end

      def icons(data, _ = nil, request = nil)
        @fields.each_value do |field|
          if field.respond_to?(:icons)
            candidate = field.icons(data, request)
            return candidate if candidate && !candidate.empty?
          end
        end
        return []
      end

      def metadata_component(data, _ = nil, request = nil)
        return data.map {|item| metadata_component(item, nil, request)}.compact if data === Array
        ret = {preview: [], medium: [], full: []}
        @fields.each_value do |field|
          if field.respond_to?(:display)
            mc_preview = field.display(:preview, data, request)
            mc_medium = field.display(:medium, data, request)
            mc_full = field.display(:full, data, request)
            ret[:preview] << mc_preview if mc_preview
            ret[:medium] << mc_medium if mc_medium
            ret[:full] << mc_full if mc_full
          end
        end
        ret
      end

      def header_component(data, _ = nil, request = nil)
        return data.map {|item| header_component(item, nil, request)}.compact if data === Array
        ret = {}
        [:preview, :medium, :full, :callno_browse].each do |display_type|
          ret[display_type] = Hash.new
          @fields.each_value do |field|
            if field.respond_to?(:header_region_display)
              rendered_display = field.header_region_display(display_type, data, request)
              unless rendered_display.nil?
                region = rendered_display[:region]
                description = rendered_display[:description]
                unless description.nil?
                  ret[display_type][region] ||= []
                  ret[display_type][region] << description
                end
              end
            end
          end
        end
        ret
      end


      def apply_fields(data, _ = nil, request = nil)
        if data === Array
          data.map { |item| apply_fields(item, nil, request) }.compact
        else
          csl = CSLAggregator.new
          z3988 = [ 'ctx_ver=Z39.88-2004', 'ctx_enc=info%3Aofi%2Fenc%3AUTF-8' ]
          ret = []
          ret << href_field(data)
          ret << datastore_field(data)
          ret << holdings_field(data) if has_holdings?
          ret << get_this_field(data) if has_get_this?
          @fields.each_value do |field|
            val = field.apply(data, request)
            z3988 << field.z3988.value(val)
            csl.merge!(field.csl.value(val))
            ret << val
          end
          ret << csl.spectrum
          if openurl = ret.find { |val| val&.fetch(:uid) == 'openurl' }&.fetch(:value)
            record_id = ret.find { |val| val&.fetch(:uid) == 'id' }&.fetch(:value) || '404-not-found'
            record_url = 'https://search.lib.umich.edu/articles/record/' + record_id
            ret << {
              uid: 'z3988',
              value: [
                openurl,
                'sid=U-M%20Library%20Search',
                "rfr_id=#{URI::encode_www_form_component(record_url)}"
              ].join('&'),
              name: 'Z3988',
              value_has_html: true
            }
          else
            ret << { uid: 'z3988', value: z3988.flatten.join("&"), name: 'Z3988', value_has_html: true }
          end
          ret.compact
        end
      end

      def value(data, name)
        if name
          data.respond_to?(:[]) ? data[name] :
           (data.respond_to?(name.to_sym) ? data.send(name.to_sym) : nil)
        end
      end

      def key_map
        @hierarchy&.key_map || {}
      end

      def value_map
        @hierarchy&.value_map || {}
      end

      def spectrum(_ = nil, args = {})
        @get_null_facets&.call
        {
          uid: @id,
          metadata: @metadata.spectrum,
          url: "#{base_url}/#{url}",
          default_sort: @default_sort.id,
          sorts: @sorts.spectrum,
          fields: @fields.spectrum,
          facets: @facets.spectrum(@facet_values, base_url, key_map, args),
          holdings: (has_holdings? ? "#{base_url}/#{url}/holdings" : nil),
          hierarchy: @hierarchy&.spectrum,
        }
      end

      def is_subsource?
        @subsource
      end

      def path(query)
        if query.empty?
          "/#{base}"
        else
          "/#{base}?q=#{URI.encode(query)}"
        end
      end

      def initialize_copy(_source)
        @facets = @facets.clone
      end

      def apply(request, results)
        clone.apply_request!(request).apply_facets!(results)
      end

      def apply_request(request)
        clone.apply_request!(request)
      end

      def apply_request!(request)
        facet = @facets[request.facet_uid]
        if facet
          facet.limit  = request.facet_limit
          facet.offset = request.facet_offset
        end
        self
      end

      def apply_facets(results)
        clone.apply_facets!(results)
      end

      def apply_facets!(results)
        if results.respond_to? :[]
          @facet_values = results['facet_counts']['facet_fields']
        elsif results.respond_to? :facets
          @facet_values = {}
          # TODO: Make a facet values object or something.
          results.facets.each do |facet|
            field = fields.values.find { |f| f.facet_field == facet.display_name }
            mapping = field&.mapping || {}
            reversed = field&.reverse_facets
            @facet_values[facet.display_name] = []
            (reversed ? facet.counts.reverse : facet.counts).each do |count|
              # unless count.applied?
              @facet_values[facet.display_name] << mapping.fetch(count.value, count.value)
              @facet_values[facet.display_name] << count.count
              # end
            end
          end
        else
          @facet_values = {}
        end

        if results.respond_to?(:range_facets)
          results.range_facets.each do |rf|
            @facet_values[rf.src['displayName']] ||= []
            rf.src['counts'].each do |count|
              @facet_values[rf.src['displayName']] << "#{count['range']['minValue']}:#{count['range']['maxValue']}"
              @facet_values[rf.src['displayName']] << count['count']
            end
          end
        end
        self
      end

      def has_facets?
        !@facets.empty?
      end

      # These need to be lazy-loaded so that rake routes will work.
      def get_null_facets
        @get_null_facets = proc do
          yield
          @get_null_facets = nil
        end
      end

      def routes(app)

        app.match "#{@url}/ids",
          to: 'json#ids',
          defaults: {source: source, focus: @id, type: 'Ids' },
          via: [:get, :options]

        app.match "#{@url}/debug",
          to: 'json#debug',
          defaults: {source: source, focus: @id, type: 'Debug' },
          via: [:get, :options]

        app.match @url,
                  to: 'json#search',
                  defaults: { source: source, focus: @id, type: 'DataStore' },
                  via: [:post, :options]

        app.match "#{@url}/browse",
                  to: "json#browse",
                  defaults: { source: source, focus: @id, type: 'DataStore' },
                  via: [:post, :options]

        app.match "#{@url}/record/*id",
                  to: 'json#record',
                  defaults: { source: source, focus: @id, type: 'Record', id_field: id_field },
                  via: [:get, :options]

        if has_holdings?
          app.match "#{url}/holdings/:id",
                    to: 'json#holdings',
                    defaults: { source: source, focus: @id, type: 'Holdings', id_field: id_field },
                    via: [:get, :options]
          app.match "#{url}/holdings/:record/:holding/:item/:pickup_location/:not_needed_after",
                    to: 'json#hold',
                    defaults: { source: source, focus: @id, type: 'PlaceHold', id_field: id_field },
                    via: [:post, :options]
          app.match "#{url}/get-this/:id/:barcode",
                    to: 'json#get_this',
                    defaults: { source: source, focus: @id, type: 'GetThis', id_field: id_field },
                    via: [:get, :options]
          app.match "#{url}/hold",
                    to: 'json#hold_redirect',
                    defaults: { source: source, focus: @id, type: 'PlaceHold', id_field: id_field },
                    via: [:post, :options]
        end

        app.get @url, to: 'json#bad_request'
        @facets.routes(source, @id, app)
      end

      def search_box
        {
          'route' => base + '_index_path',
          'placeholder' => placeholder
        }
      end

      def configure_blacklight(config, request)
        added = {}
        @fields.each do |f|
          fname = f.field
          fname = fname.last if Array === fname
          next if added[fname]
          config.add_search_field fname, label: f.name if f.searchable?
          config.add_index_field fname, label: f.name
          config.add_show_field fname, label: f.name
          added[fname] = true
        end

        @facets.native_pair do |solr_name, facet|
          config.add_facet_field solr_name,
                                 label:  facet.name,
                                 sort:   request.facet_sort || facet.sort,
                                 include_in_request: true,
                                 solr_params: {
                                   'facet.mincount' => facet.mincount,
                                   'facet.limit' => (request.facet_limit  || facet.limit),
                                   'facet.offset' => request.facet_offset || facet.offset
                                 }
        end

        config.max_per_page = @max_per_page
      end

      def category_match(cat)
        self if cat == :all || cat == category
      end

      def fetch_record(sources, id, role = 'authenticated', request = nil)
        apply_fields(sources[source].fetch_record(id_field, id, role), nil, request)
      end

      def <=>(other)
        weight <=> other.weight
      end

      def get_basic_sorts(request)
        sorts.values.find { |sort| sort.uid == request.sort } || default_sort
      end

      def get_sorts(request)
        highly_recommended.get_sorts(get_basic_sorts(request), request.facets)
      end

      private
      def summon_escape(str)
        str.gsub(/([\\,\{\}\(\)\[\]\&|!:])/, '\\\\\1')
      end
    end
  end
end
