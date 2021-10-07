# frozen_string_literal: true

module Spectrum
  module Response
    class Text
      attr_accessor :request, :driver

      def initialize(request)
        self.request = request
        self.driver  = Spectrum::Json.actions['text'].driver
      end

      def spectrum
        return needs_authentication unless request.logged_in?
        return invalid_number unless request.to =~ /^\d{10,10}$/
        result = driver.message(request.to, request.items)
        if result.all? { |message| message.status == 'accepted' }
          success
        elsif result.any? { |message| message.status == 'accepted' }
          failure
        else
          failure
        end.merge(
          details: {
            requested: request.items.length,
            success: result.select { |message| message.status == 'accepted' }.length,
            failure: result.reject { |message| message.status == 'accepted' }.length
          }
        )
      rescue Exception => e
        Rails.logger.error { e.to_s + e.backtrace.to_s}
        failure
      end

      private

      def success
        {
          status: 'Success',
          status_code: 'action.response.success',
          description: 'Success'
        }
      end

      def failure
        {
          status: 'Failure',
          status_code: 'action.response.unknown.error',
          description: "We're sorry. Something went wrong. Please use <a href='https://www.lib.umich.edu/ask-librarian'>Ask a Librarian</a> for help."
        }
      end

      def invalid_number
        {
          status: 'Failure',
          status_code: 'action.response.invalid.number',
          description: 'Please enter a valid 10-digit phone number (e.g. 734-123-4567)',
        }
      end

      def needs_authentication
        {
          status: 'Not logged in',
          status_code: 'action.response.authentication.required',
          description: 'Not logged in'
        }
      end
    end
  end
end
