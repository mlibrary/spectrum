# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class SourceList < ConfigList
      CONTAINS = Source
      def routes(config)
        __getobj__.values.each { |source| source.routes(config) }
      end
    end
  end
end
