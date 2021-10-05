# frozen_string_literal: true
module Spectrum
  module Config
    class Sort
      attr_accessor :weight, :id, :value, :metadata, :uid

      def initialize(args = {})
        @id       = args['id']
        @uid      = args['uid'] || @id
        @value    = args['value']  || args['id']
        @group    = args['group']  || args['id']
        @weight   = args['weight'] || 0
        @metadata = Metadata.new(args['metadata'])
      end

      def spectrum
        {
          uid: @uid,
          metadata: @metadata.spectrum,
          group: @group
        }
      end

      def <=>(other)
        weight <=> other.weight
      end

      def [](field)
        send(field.to_sym) if respond_to?(field.to_sym)
      end
    end
  end
end
