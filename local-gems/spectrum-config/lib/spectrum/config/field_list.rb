# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Spectrum
  module Config
    class FieldList < ConfigList
      CONTAINS = Field

      def by_uid(uid)
        __getobj__.values.each do |f|
          return f if f.uid == uid
        end
        nil
      end

      def each
        __getobj__.values.each { |f| yield f }
      end

      def apply(data)
        data.map { |item| apply_fields(item) }.compact
      end

      def apply_fields(item)
        __getobj__.map { |_field| item }.compact
      end

      def list
        __getobj__.map { |field| field.list? ? field : nil }.compact
      end

      def full
        __getobj__.map { |field| field.full? ? field : nil }.compact
      end
    end
  end
end
