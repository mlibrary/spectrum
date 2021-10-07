# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class FacetList < MappedConfigList
      CONTAINS = Facet

      def initialize(*args)
        if Array === args.first
          begin
            uids = args.shift
            all_fields = args.shift.values
            fields = uids.map {|uid| all_fields.find {|f| f.id == uid}}
            @mapping     = {}
            @reverse_map = {}
            @native_pair = {}
            obj          = {}
            fields.each do |f|
              @native_pair[f.facet_field] = f.id
              @mapping[f.facet_field] = f.uid
              @reverse_map[f.uid] = f.facet_field
              obj[f.id] = if f.class == self.class::CONTAINS
                f
              else
                self.class::CONTAINS.new(f, *args)
              end
            end
            available_uids = fields.map(&:uid)
            raise "Missing mapped #{self.class::CONTAINS} id(s) #{(@mapping.values - available_ids).join(', ')}" unless (@mapping.values - available_uids).empty?
            __setobj__(obj)
          rescue
            STDERR.puts self.class
            STDERR.puts self.class::CONTAINS
            raise
          end
        else
          super(*args)
          @native_pair = @mapping
        end
      end

      # initialize_copy wasn't being triggered.
      def clone
        newobj = super
        newobj.instance_eval do
          __getobj__.each_pair do |k, v|
            __getobj__[k] = v.clone
          end
        end
        newobj
      end

      def native_pair
        @native_pair.each_pair do |native, logical|
          yield native, __getobj__[logical]
        end
      end

      def facet(name, data, base_url)
        (this_facet = __getobj__[name]).spectrum(data[this_facet.facet_field], base_url)
      end

      def spectrum(data, base_url, key_map, args = {})
        __getobj__.values.map { |facet| facet.spectrum(data[facet.facet_field], base_url, key_map, args) }
      end

      def routes(source, focus, app)
        __getobj__.values.each { |facet| facet.routes(source, focus, app) }
      end
    end
  end
end
