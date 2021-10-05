# frozen_string_literal: true

module Spectrum
  module Response
    class Email
      attr_accessor :request, :driver

      def initialize(request)
        self.request = request
        self.driver  = Spectrum::Json.actions['email'].driver
      end

      def spectrum
        return needs_authentication unless request.logged_in?
        return invalid_email unless request.to =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        result = driver.message(request.to, request.from, request.items)
        success
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

      def invalid_email
        {
          status_code: 'action.response.invalid.email',
          description: 'Please enter a valid email address (e.g. uniqname@umich.edu)',
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
