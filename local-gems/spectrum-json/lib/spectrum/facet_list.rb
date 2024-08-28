# frozen_string_literal: true

module Spectrum
  class FacetList
    attr_reader :data

    def find(field)
      [data.map { |key,value| key == field && value }].flatten(2).compact
    end

    def initialize(data)
      @data = data
    end

    def q_include
      (@data || {}).map do |category, value|
        [value].flatten(1).map do |val|
          "facet_#{category},exact,#{val}"
        end
      end.flatten.join('|,|')
    end

    def spectrum
      @data || {}
    end

    def fvf(filter_map = {})
      ret = []
      @data&.each_pair do |key, value|
        if value.is_a?(Array)
          value.each do |item|
            ret << "#{filter_map[key] || key},#{summon_escape(item)},false"
          end
        else
          ret << "#{filter_map[key] || key},#{summon_escape(value)},false"
        end
      end
      ret
    end

    def query(filter_map = {}, value_map = {}, focus = nil, request = nil)
      ret = []
      @data&.each_pair do |original_key, value|
        key = filter_map.fetch(original_key, original_key)
        value = Array(value).map do |v|

          facet = focus.facet_by_field_name(key)
          if facet
            v = facet.conditional_query_map(request, v)
          end

          mapped_value = if value_map.has_key?(original_key)
            value_map.fetch(original_key, {}).fetch(v, v)
          else
            value_map.fetch(key, {}).fetch(v, v)
          end
          [mapped_value].flatten.map {|v| solr_escape(v)}.join(' OR ')
        end.reject do |v|
          v == '*' || v == '\*'
        end.join(' AND ')

        if key == 'date_of_publication' || original_key == 'date_of_publication'
          raw_value = value.gsub(/\\/, '')
          raw_value.match(/^before\s*(\d+)$/) do |m|
            value = "[* TO #{m[1]}]"
          end
          raw_value.match(/^after\s*(\d+)$/) do |m|
            value = "[#{m[1]} TO *]"
          end
          raw_value.match(/^(\d+)\s*to\s*(\d+)$/) do |m|
            value = "[#{m[1]} TO #{m[2]}]"
          end
        end
        ret << "#{key}:(#{value})" unless value.empty?
      end
      ret
    end

    private

    def summon_escape(string)
      string.gsub(/([\\,\{\}\(\)\[\]\&|!:])/, '\\\\\1')
    end

    def solr_escape(string)
      RSolr.solr_escape(string).gsub(/\s+/, '\\ ')
    end
  end
end
