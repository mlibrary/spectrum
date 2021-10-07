module Spectrum
  module Response
    class Action
      attr_accessor :request

      def initialize(request)
        self.request = request
      end

      def spectrum
        success
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
