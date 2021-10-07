# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class SortList < MappedConfigList
      CONTAINS = Sort
      def default
        __getobj__.values.first
      end
    end
  end
end
