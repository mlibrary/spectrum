# frozen_string_literal: true
module Spectrum
  module Config
    class CommaSeparatedField < Field
      type 'comma_separated'

      attr_reader :fields, :glue, :min

      def initialize_from_instance(i)
        super
        @fields = i.fields
        @glue = i.glue
        @min  = i.min
      end

      def initialize_from_hash(args, config)
        super

        @glue = args['glue'] || ', '
        @min  = args['min'].to_i || 2
        @fields = args['fields'].map do |fname|
          Field.new(
            {'id' => SecureRandom.uuid, 'metadata' => {}, 'field' => fname},
            config
          )
        end
      end

      def value(data, request = nil)
        values = fields.map {|field| [field.value(data)].flatten.first}.compact
        return nil if values.empty? || values.length < min
        values.join(glue)
      end
    end
  end
end
