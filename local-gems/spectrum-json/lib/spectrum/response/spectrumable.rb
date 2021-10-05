# frozen_string_literal: true

module Spectrum
  module Response
    module Spectrumable
      extend ActiveSupport::Concern

      def initialize(args = {})
        @data = args
      end

      def spectrum(args = {})
        if @data.respond_to?(:spectrum)
          @data.spectrum(args)
        else
          @data
        end
      end
    end
  end
end
