# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class NullSource < BaseSource
    end

    module Source
      def self.new(args)
        case args['type']
        when 'summon', :summon
          SummonSource.new args
        when 'solr', :solr
          SolrSource.new args
        when 'primo', :primo
          PrimoSource.new args
        else
          NullSource.new args
        end
      end
    end
  end
end
