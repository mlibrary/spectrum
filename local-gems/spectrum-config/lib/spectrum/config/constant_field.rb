# frozen_string_literal: true
module Spectrum
  module Config
    class ConstantField < Field
      type 'constant'

      attr_reader :constant

      def initialize_from_instance(i)
        super
        @constant = i.constant
      end

      def initialize_from_hash(args, config)
        super
        @constant = args['constant']
      end

      def value(_, _ = nil)
        return constant
      end
    end
  end
end
