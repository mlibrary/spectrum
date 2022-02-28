module Spectrum
  module Config
    class PrimoSource < BaseSource

      attr_accessor :key, :host, :tab, :scope, :view

      def fetch_record(field, id, _ = nil)
        Spectrum::SearchEngines::Primo::Engine.new(
          key: key,
          host: host,
          tab: tab,
          scope: scope,
          view: view,
          params: { q: "#{field},exact,#{id}" }
        ).results&.first || {}
      end

      def initialize(args)
        super(args)
        @key   = args['key']
        @host  = args['host']
        @tab   = args['tab']
        @scope = args['scope']
        @view  = args['view']
      end

      def engine(focus, request, controller = nil)
        Spectrum::SearchEngines::Primo::Engine.new(
          key: key,
          host: host,
          tab: tab,
          scope: scope,
          view: view,
          params: params(focus, request, controller)
        )
      end

      def extract_query(field_mapping, field, conjunction, tree )
        if tree.is_type?('tokens')
          return "#{field_mapping.fetch(field, field)},exact,#{tree.text}"
        elsif ['and', 'or'].any? { |type| tree.is_type?(type) }
          op = tree.operator.to_s.upcase
          return tree.children.map do |child|
            extract_query(field_mapping, field, op, child)
          end.join(",#{op};")
        elsif tree.is_type?('not')
          return ",NOT;" + tree.children.map do |child|
             extract_query(field_mapping, field, 'NOT', child)
          end.join(",NOT;")
        elsif tree.is_type?('fielded')
          return extract_query(field_mapping, tree.field, conjunction, tree.query)
        elsif tree.root_node?
          return 'any,contains,*' if tree.children.empty?
          return tree.children.map do |child|
            extract_query(field_mapping, field, conjunction, child)
          end.
            join(",#{conjunction};").
            gsub(/,(AND|OR);,NOT;/, ',NOT;').
            gsub(/^,NOT;/, 'any,contains,*,NOT;')
        else
          return ''
        end
      end

      def extract_record_query(request)
        {
          q: "id,exact,#{request.instance_eval {@request.params}['id']}"
        }
      end

      def date_range(value)
        return value if value.nil? || value.empty?
        value = value.to_s
        if value.match(/^\d+$/)
          "[#{value} TO #{value}]"
        elsif (m = value.match(/^before\s*(\d+)$/))
          "[* TO #{m[1]}]"
        elsif (m = value.match(/^after\s*(\d+)$/))
          "[#{m[1]} TO *]"
        elsif (m = value.match(/^(\d+)\s*to\s*(\d+)$/))
          "[#{m[1]} TO #{m[2]}]"
        else
          value
        end
      end

      def extract_facets(request)
        return {} if request.facets.data.nil? || request.facets.data.empty?

        retval = { qInclude: [], qExclude: [], pcAvailability: []}
        facet_definitions = request.instance_eval { @focus.instance_eval { @facets } }

        request.facets.data.each_pair do |key, values|
          definition = facet_definitions.values.find { |f| [f.id, f.uid].include?(key) }
          next unless definition

          [values].flatten.each do |value|
            value = definition.mapping.fetch(value, value)
            value = self.send(definition.transform, value) if definition.transform

            if value.start_with?('qInclude=')
              retval[:qInclude] << value[9, value.length]
            elsif value.start_with?('qExclude=')
              retval[:qExclude] << value[9, value.length]
            elsif value.start_with?('pcAvailability=')
              retval[:pcAvailability] << value[15, value.length]
            else
              retval[:qInclude] << "facet_#{definition.facet_field},exact,#{value}"
            end
          end
        end

        retval.reject {|key, val| val.empty?}.map {|key, val| [key, val.join('|,|')]}.to_h
      end

      def extract_offset(request)
        request.start
      end

      def extract_limit(request)
        return 1 if request.count <= 0
        request.count
      end

      def extract_sort(focus, request)
        return focus.default_sort.value unless request.sort
        (focus.sorts.values.find do |sort|
          sort.uid == request.sort
        end || focus.default_sort)&.value
      end

      def params(focus, request, controller)

        if Spectrum::Request::Record === request
          return extract_record_query(request)
        end

        field_mapping = focus.fields.values.map { |f| [f.uid, f.query_field]}.to_h

        {
          q: extract_query(
            field_mapping,
            focus.raw_config['search_field_default'] || 'any',
            'AND',
            request.build_psearch.search_tree
          ),
          offset: extract_offset(request),
          limit: extract_limit(request),
          sort: extract_sort(focus, request),
        }.merge(extract_facets(request))

      end
    end
  end
end
