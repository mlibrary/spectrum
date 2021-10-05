# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class BaseSource
      attr_accessor :url, :type, :id, :driver, :path, :id_field, :holdings
      def initialize(args)
        @id        = args['id']
        @id_field  = args['id_field'] || 'id'
        @name      = args['name']
        @url       = args['url']
        @type      = args['type']
        @driver    = args['driver']
        @link_key  = args['link_key']  || 'id'
        @link_type = args['link_type'] || :relative
        @link_base = args['link_base']
        @holdings  = args['holdings']
        @conditionals = args['conditionals'] || {}
      end

      def fetch_record(field, id, _ = nil)
        client = driver.constantize.connect(url: url)
        result = client.get('select', params: { q: "#{field}:#{RSolr.solr_escape(id)}" })
        return {} unless result &&
                         result['response'] &&
                         result['response']['docs']
        result['response']['docs'].first || {}
      end

      def link_to(base, doc)
        send @link_type, base, doc
      end

      def is_solr?
        false
      end

      def <=>(b)
        id <=> b.id
      end

      def merge!(args = {})
        args.each_pair do |k, v|
          send (k.to_s + '=').to_sym, v
        end
      end

      def [](key)
        send key.to_sym
      end

      def params(focus, request, _controller = nil)
        request.query(focus.fields, focus.facet_map).merge(source: self,
                                                           'source' => self)
      end

      def engine(_focus, _request, _controller = nil)
        nil
      end

      private

      def first_value(doc, key)
        doc[key].listify.first
      end

      def rebase(_base, doc)
        relative @link_base, doc
      end

      def relative(base, doc)
        "#{base}/#{first_value(doc, @link_key)}"
      end

      def absolute(_base, doc)
        first_value doc, @link_key
      end
    end
  end
end
