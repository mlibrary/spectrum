# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class SearchField
      attr_accessor :name, :label, :dropdown, :parameters,
                    :local_parameters, :qt

      def initialize(data)
        init_with data
      end

      def init_with(data)
        @qt         = data['qt'] || nil
        @name       = data['name']
        @label      = data['label'] || data['name'].capitalize
        @dropdown   = data['dropdown'] || false
        @parameters = data['parameters'] || {}
        @local_parameters = data['local_parameters'] || {}
      end

      def dropdown?
        @dropdown == true
      end

      def configure(config)
        config.add_search_field(name) do |field|
          field.show_in_dropdown = dropdown?
          field.label = label
          field.solr_local_parameters = local_parameters
          p = parameters.deep_clone
          p.each_pair do |key, value|
            value.push(config.default_solr_params(key)) if
              config.default_solr_params(key)
          end
          field.solr_parameters = parameters
          field.qt = qt if qt
        end
      end
    end
  end
end
