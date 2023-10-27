# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

require 'htmlentities'
require 'rails/html/sanitizer'

module Spectrum
  module Config
    class Filter
      attr_accessor :id, :method

      def initialize(data)
        @id     = data['id']
        @method = data['method'].to_sym
        @decoder = HTMLEntities.new
      end

      def boolean(value, request)
        case value
        when Array
          value.map { |val| boolean(val, request) }
        when 'true', true, 'yes', 'Yes'
          'Yes'
        when 'false', false, 'no', 'No'
          nil
        else
          value
        end
      end

      def proxy_prefix(value, request)
        case value
        when Array
          value.map { |val| proxy_prefix(val, request) }
        when String
          add_prefix(request.proxy_prefix, value)
        when Hash
          if value['uid'] == 'href'
            value.merge('value' => add_prefix(request.proxy_prefix, value['value']))
          elsif value[:uid] == 'href'
            value.merge(value: add_prefix(request.proxy_prefix, value[:value]))
          elsif value[:rows]
            value.merge(rows: value[:rows].map { |row| proxy_prefix(row, request) } )
          elsif value[:href]
            value.merge(href: add_prefix(request.proxy_prefix, value[:href]))
          elsif value['href']
            value.merge('href' => add_prefix(request.proxy_prefix, value['href']))
          elsif value[:description]
            value.merge(description: proxy_prefix(value[:description], request))
          else
            value
          end
        else
          value
        end
      end

      def add_prefix(prefix, value)
        return value unless value
        return value if value.include?('proxy.lib.umich.edu')
        return value if value.include?('libproxy.umflint.edu')
        prefix + URI::encode_www_form_component(value)
      end

      def <=>(other)
        if other.respond_to? :id
          @id <=> other.id
        elsif other.respond_to? :to_s
          @id <=> other.to_s
        else
          0
        end
      end

      def apply(value, request)
        send(method, value, request)
      end

      def sanitize(value, _)
        if String === value
          @decoder.decode(Rails::Html::FullSanitizer.new.sanitize(value))
        elsif value.respond_to?(:map) && value.all? { |item| String === item }
          value.map do |item|
            sanitize(item, nil)
          end
        else
          value
        end
      end

      def truncate(value, _)
        if String === value
          if value.length > 128
            value[0, 127] + "\u2026"
          else
            value
          end
        elsif value.respond_to?(:map) && value.all? { |item| String === item }
          value.map do |item|
            truncate(item, nil)
          end
        else
          value
        end
      end

      def trim2(value, _)
        if String === value
          value.sub(%r{\s*,\s*$}, '')
        elsif value.respond_to?(:map) && value.all? { |item| String === item }
          value.map do |item|
            trim2(item, nil)
          end
        else
          value
        end
      end

      def trim(value, _)
        if String === value
          value.sub(%r{(\S{3,})\s*[/.,:]$}, '\1')
        elsif value.respond_to?(:map) && value.all? { |item| String === item }
          value.map do |item|
            trim(item, nil)
          end
        else
          value
        end
      end

      def decode(value, _)
        if String === value
          @decoder.decode(value)
        elsif value.respond_to?(:map) && value.all? { |item| String === item }
          value.map do |item|
            @decoder.decode(item)
          end
        else
          value
        end
      end

      def unless9(value, _)
        if value.respond_to?(:map)
          list = value.map { |item| unless9(item, nil) }.compact
          if list.empty?
            nil
          else
            list
          end
        elsif value.respond_to?(:length) && value.length == 9
          nil
        else
          value
        end
      end

      def uniq(value, _)
        if value.respond_to?(:uniq)
          value.uniq
        else
          value
        end
      end

      def fullname(value, _)
        if value.respond_to?(:map)
          value.map(&:fullname)
        elsif value.respond_to?(:fullname)
          value.fullname
        else
          value
        end
      end

      def marc555text(value, _)
        value
          .sub(%r{ via World Wide Web at URL:.*},' online')
          .sub(%r{ via the World Wide Web at URL:.*}, ' online')
          .sub(%r{ via the World Wide web at URL:.*}, ' online')
          .sub(%r{ via the World Wide Web\.\.*}, ' online')
          .sub(%r{ via the Internet\..*}, ' online')
          .sub(%r{ available at http.*}, ' available online')
          .sub(%r{: http.*}, ' available online')
      end

      def marc555href(value, _)
        return nil if value.nil? || value.empty? || !value.include?('http')
        value.sub(%r{^.*http}, 'http')
      end

      def marc555(value, _)
       if Array === value
         if value.all? { |val| Array === val }
           value.map { |val| marc555(val, _) }
         elsif value.all? { |val| Hash === val }
           value.map do |val|
             marc555(val, _)
           end.compact.inject({'text' => [], 'href' => []}) do |acc, val|
             key = val[:uid]
             acc[key] = acc[key] + [val[:value]].flatten(1).compact
             acc
           end.tap do |hsh|
             hsh['text'] = hsh['text'].join(' ')
             hsh['href'] = hsh['href'].first
           end
         end.compact
       elsif Hash === value
         candidate_method = method.to_s + value[:uid]
         candidate_value = if respond_to?(candidate_method)
           send(candidate_method, value[:value], _)
         else
           value[:value]
         end
         return nil if candidate_value.nil? || candidate_value.empty?
         value.merge(value: candidate_value)
       end
      end

      def marc_300_a(value, request)
        case value
        when Array
          value.map { |val| marc_300_a(val, request) }
        when String
          return nil if value.match(/[^A-Za-z0-9]/)
          value
        end
      end

      def ris_text(value, request)
        case value
        when Array
          value.map { |val| ris_text(val, request) }
        when String
          value.gsub(/ : /, ': ').gsub(/ ?[\/:]$/, '')
        end
      end
    end
  end
end
