# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class MappedConfigList < SimpleDelegator
      CONTAINS = NullConfig

      attr_reader :mapping, :reverse_map

      def initialize(mapping = {}, list = {}, *rest)
        @reverse_map = {}
        if mapping.respond_to?(:inject) && !mapping.respond_to?(:keys)
          @mapping = mapping.each_with_object({}) { |item, memo| memo[item['id']] = item['id']; }
          rest.unshift(list) unless list.empty?
          list = mapping.each_with_object({}) { |item, memo| memo[item['id']] = item; }
        else
          @mapping = mapping || {}
        end

        @reverse_map = @mapping.invert

        raise "Missing mapped #{self.class::CONTAINS} id(s) #{(@mapping.values - list.keys).join(', ')}" unless (@mapping.values - list.keys).empty?

        __setobj__(
          @mapping.values.map { |id| list[id] }.compact.map do |item|
            if item.class == self.class::CONTAINS
              item
            else
              self.class::CONTAINS.new(item, *rest)
            end
          end.sort.each_with_object({}) do |val, ret|
            ret[val.id] = val
          end
        )
      rescue
        STDERR.puts self.class
        STDERR.puts self.class::CONTAINS
        raise
      end

      def native_pair
        @mapping.each_pair do |native, logical|
          yield native, __getobj__[logical]
        end
      end

      def total_available
        __getobj__.values.length
      end

      def spectrum
        __getobj__.values.map(&:spectrum).compact
      end
    end
  end
end
