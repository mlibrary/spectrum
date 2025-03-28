# frozen_string_literal: true

module Keycard
  module Rack
    # Rack middleware to return 403/Access denied status
    class RequireInstitution
      attr_accessor :app, :institution
      def initialize(app, institution = :any)
        @app = app
        @institution = institution
      end

      def call(env)
        return app.call(env) if match?(env['dlpsInstitutionId'])
        access_denied
      end

      private

      def match?(request)
        return false if request.blank?
        return true if institution == :any
        # rubocop:disable Style/CaseEquality
        Array(institution).any? { |app_inst| request.any? { |request_inst| app_inst === request_inst } }
        # rubocop:enable Style/CaseEquality
      end

      def access_denied
        [403, { 'Content-Type' => 'text/html' }, ['Access Denied']]
      end
    end
  end
end
