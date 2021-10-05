# frozen_string_literal: true
module Spectrum
  module Config
    class Bookplate
      attr_reader :id, :uid, :desc, :image
      def initialize(data)
        @id = @uid = data['uid']
        @desc = data['desc']
        @image = data['image']
      end

      def <=>(other)
        id <=> other.id
      end
    end
  end
end
