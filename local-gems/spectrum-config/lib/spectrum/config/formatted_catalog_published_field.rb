# frozen_string_literal: true
module Spectrum
  module Config
    class FormattedCatalogPublishedField < Field
      type 'formatted_catalog_published'

      attr_reader :date, :groups
      def initialize_from_instance(i)
        super
        @date = i.date
        @groups = i.groups
      end

      def initialize_from_hash(args, config)
        super
        @groups = args['groups'].map do |fdef|
          Field.new(
            fdef.merge('id' => SecureRandom.uuid, 'metadata' => {}),
            config
          )
        end
        @date = Field.new(
          args['date'].merge('id' => SecureRandom.uuid, 'metadata' => {}),
          config
        )
      end

      def get_date_val(data)
        date_val = [@date.value(data)].flatten.first
        return date_val.strip unless date_val.nil?
        date_val
      end

      def get_pub_vals(data)
        date_val = get_date_val(data)

        @groups.map do |group|
          values = [group.value(data)].flatten(1).reject do |item|
            item.nil? || item.empty?
          end.map do |item|
            [
              (item.find {|fl| fl[:uid] == 'ab'} || {})[:value],
              date_val || (item.find {|fl| fl[:uid] == 'c'} || {})[:value]
            ].flatten.reject do |val|
              val.nil? || !(String === val) || val.empty?
            end.join(' ')
          end
          values.empty? ? nil : values
        end.compact.flatten
      end

      def value(data, request = nil)
        pub_vals = get_pub_vals(data)
        return nil if pub_vals.empty?
        pub_vals
      end
    end
  end
end
