# frozen_string_literal: true

module Spectrum
  module Response
    class PlaceHold
      attr_reader :hold
      def initialize(request)
        @valid_account = request.valid_account?
        @logged_in = request.logged_in?
        @success_message = request.success_message
        @failure_message = {}
        return unless @valid_account
        @hold = Spectrum::Entities::AlmaHold.for(request: request).create!

      end

      def renderable
        return { status: 'Not logged in' } unless @logged_in
        return { status: 'No account' } unless @valid_account
        {
          status: hold.success? ? 'Action Succeeded' : hold.error_message,
          orientation: hold.success? ? @success_message : @failure_message
        }
      end
    end
  end
end
