# frozen_string_literal: true
module Spectrum
  module Config
    class NullFacet
      attr_accessor :weight, :id, :limit, :mincount, :offset
      attr_reader :uid, :field, :type, :expanded, :condition
      DEFAULT_SORTS = {}.freeze
      def initialize
        @facet_field = @field = @uid = @id = 'null'
        @more = false
        @fixed = false
        @values = []
        @default = false
        @required = false
        @mincount = 1
        @limit = 50
        @offset = 0
        @metadata = Metadata.new('name' => 'Null Facet')
        @url = 'null'
        @type = 'null'
        @sorts = SortList.new
        @default_sort = nil
        @ranges = nil
        @condition = nil
      end

      [:pseudo_facet?, :rff, :routes, :sort, :label, :values, :spectrum, :name, :<=>, :more].each do |fn|
        define_method(fn) { |*arg| }
      end

      def mapping
        {}
      end

      def conditional_map(_, values)
        values
      end

      def conditional_query_map(_, value)
        value
      end
    end

    class Facet
      attr_accessor :weight, :id, :limit, :mincount, :offset

      attr_reader :uid, :field, :type, :facet_field, :selected, :mapping, :transform, :condition

      DEFAULT_SORTS = { 'count' => 'count', 'index' => 'index' }.freeze

      def initialize(args = {}, sort_list = [], url = '')
        @id           = args['id']
        @uid          = args['uid'] || @id
        @field        = args['field'] || @uid
        @facet_field  = args['facet_field'] || @field
        @more         = args['more']     || false
        @fixed        = args['fixed']    || false
        @values       = args['values']   || []
        @default      = args['default']  || false
        @required     = args['required'] || false
        @mincount     = args['mincount'] || 1
        @limit        = args['limit']    || 50
        @offset       = args['offset']   || 0
        @metadata     = Metadata.new(args['metadata'])
        @url          = url + '/' + @uid
        @type         = args['facet'].type || args['type'] || args.type
        @ranges       = args['facet'].ranges
        @expanded     = args['facet'].expanded || false
        @selected     = args['facet'].selected || false
        @transform    = args['facet'].transform
        @mapping      = args['mapping'] || {}
        @condition    = args['condition']

        sorts         = args['facet_sorts'] || DEFAULT_SORTS
        @sorts        = Spectrum::Config::SortList.new(sorts, sort_list)
        @default_sort = @sorts[args['default_facet_sort']] || @sorts.default
      end

      def spectrum_type
        return 'checkbox' if checkbox?
        return 'hidden' if hidden?
        'multiselect'
      end

      def hidden?
        @type == 'hidden'
      end

      def checkbox?
        pseudo_facet? || @type == 'checkbox'
      end

      def pseudo_facet?
        @type == 'pseudo_facet' || @type == 'mapped_pseudo_facet'
      end

      # The mapped_pseudo_facet looks more like a true facet.
      def true_facet?
        @type != 'pseudo_facet'
      end

      def conditional_query_map(request, value)
        return value unless @type == 'conditional_mapped_facet'
        if condition == 'request.search_only?'
          key = request.search_only?.to_s
          mapping[key].invert.fetch(value, value)
        else
          value
        end
      end

      def conditional_map(request, values)
        return values unless @type == 'conditional_mapped_facet'
        if condition == 'request.search_only?'
          condition_key = request.search_only?.to_s
          new_values = []
          i = 0;
          while i < values.length
            mapped_value = mapping.dig(condition_key, values[i])
            if mapped_value
              new_values << mapped_value
              new_values << values[i+1]
            end
            i += 2
          end
          return new_values
        end
        values
      end

      def rff(applied)
        return nil if @ranges.nil? || @ranges.empty?
        return [field, *@ranges.map { |r| r['value'] }].join(',') unless applied.data[@uid]

        values = Array(applied.data[@uid])
        range_matches = @ranges.find_all { |r| values.include?(r['value']) }
        return nil if range_matches.length != values.length
        return nil unless range_matches.all? { |r| r['divisible'] }
        list = [field]
        values.each do |value|
          start, finish = value.split(/:/).map(&:to_i)
          (start..finish).each do |i|
            list << "#{i}:#{i}"
          end
        end
        list.join(',')
      end

      def routes(source, focus, app)
        app.match @url,
                  to: 'json#facet',
                  defaults: { source: source, focus: focus, facet: @id, type: 'Facet' },
                  via: [:post, :options]
        app.get @url, to: 'json#bad_request'
      end

      def sort
        @default_sort.id
      end

      def more(data, base_url)
        if data.length > @limit * 2
          base_url + @url
        else
          false
        end
      end

      def label(value)
        if @type == 'range'
          range = @ranges.find { |range| range['value'] == value }
          return range['label'] if range && range['label']
          range = value.split(/:/).map(&:to_i)
          return range.first.to_s if range[0] == range[1]
        end
        value
      end

      def parents(value)
        Spectrum::Config::FacetParents.find(uid, value)
      end

      def values(data, lim = nil, key_map = {})
        lim ||= @limit
        if lim >= 0 && data.length > lim * 2
          data.slice(0, lim * 2)
        else
          data
        end.each_slice(2).map do |kv|
          {
            value: get_key(kv[0], key_map),
            name: label(kv[0]),
            count: kv[1],
            parents: parents(kv[0])
          }
        end.reject { |i| i[:count] <= 0 || i[:value].nil? }
      end

      def get_key(key, key_map)
        return key if key_map.nil? || key_map.empty?
        return key if key_map[id].nil? || key_map[id].empty?
        key_map[id][key]
      end

      def spectrum(data, base_url, key_map, args = {})
        data ||= []
        data = @values if data.empty?
        {
          uid: @uid,
          default_value: @default,
          values: values(data, args[:filter_limit], key_map),
          fixed: @fixed,
          required: @required,
          more: more(data, base_url),
          sorts: @sorts.spectrum,
          default_sort: @default_sort.id,
          preExpanded: @expanded,
          metadata: @metadata.spectrum,
          type: spectrum_type,
          preSelected: selected,
        }
      end

      def name
        @metadata.name
      end

      def <=>(other)
        weight <=> other.weight
      end
    end
  end
end
