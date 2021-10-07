# frozen_string_literal: true

module Spectrum
  module Response
    class Message
      TYPES = %i[error warning success info].freeze
      DEFAULT_TYPE = 'info'
      def initialize(args = {})
        @class = TYPES.include?(args[:class]) ? args[:class] : DEFAULT_TYPE
        @summary = args[:summary]
        @details = args[:details]
        @data    = args[:data]
      end

      class << self
        TYPES.each do |type|
          define_method(type) do |args = {}|
            new({ class: type }.merge(args))
          end
        end
        alias warn warning
      end

      def spectrum
        { class: @class, summary: @summary, details: @details, data: @data }
      end
    end
  end
end
