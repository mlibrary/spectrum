# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class FilterList < MappedConfigList
      CONTAINS = Filter

      def apply(value, request)
        if __getobj__.empty?
          value
        else
          __getobj__.values.inject(value) { |memo, filter| filter.apply(memo, request) }
        end
      end
    end
  end
end
