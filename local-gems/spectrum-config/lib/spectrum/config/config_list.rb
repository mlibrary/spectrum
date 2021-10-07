# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class ConfigList < SimpleDelegator
      CONTAINS = NullConfig

      def initialize(list = [], *rest)
        list ||= []
        __setobj__(
          list.map do |item|
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

      def total_available
        __getobj__.values.length
      end

      def spectrum
        __getobj__.values.map(&:spectrum).compact
      end
    end
  end
end
