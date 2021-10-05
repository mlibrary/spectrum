# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class SearchFieldList < SimpleDelegator
      def self.load(file)
        new YAML.safe_load(File.read(file))
      end

      def initialize(field_list)
        @delegate_sd_obj = field_list.each_with_object({}) do |field, memo|
          memo[field['name']] = SearchField.new(field)
        end
      end

      def configure(config, list)
        list.each do |name|
          @delegate_sd_obj[name].configure(config) if @delegate_sd_obj.key? name
        end
      end
    end
  end
end
