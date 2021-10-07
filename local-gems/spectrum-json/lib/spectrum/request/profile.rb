# frozen_string_literal: true

module Spectrum
  module Request
    class Profile
      FLINT = 'Flint'
      FLINT_PROXY = 'https://login.libproxy.umflint.edu/login?url='
      DEARBORN = 'Dearborn'
      DEARBORN_PROXY = 'https://library.umd.umich.edu/verify/fwd.php?'
      ANN_ARBOR_PROXY = 'https://proxy.lib.umich.edu/login?url='
      DEFAULT_DOMAIN = '@umich.edu'
      LOGGED_IN = 'Logged in'
      NOT_LOGGED_IN = 'Not logged in'
      REMOTE_USER = 'HTTP_X_REMOTE_USER'
      INSTITUTION_KEY = 'dlpsInstitutionId'

      attr_reader :request

      def initialize(request)
        @request = request
      end

      def status
        return LOGGED_IN if logged_in?
        NOT_LOGGED_IN
      end

      def logged_in?
        @logged_in ||= !(username.nil? || username.empty?)
      end

      def sms
        return nil unless logged_in?
        @sms ||= Spectrum::Entities::AlmaUser.for(username: username).sms
      end

      def username
        @username ||= request.env[REMOTE_USER]
      end

      def email
        return nil unless logged_in?
        return username if username.include?('@')
        username + DEFAULT_DOMAIN
      end

      def institutions
        @institutions ||= (request.env[INSTITUTION_KEY] || [])
      end

      def proxy_prefix
        return FLINT_PROXY if institutions.include?(FLINT)
        return DEARBORN_PROXY if institutions.include?(DEARBORN)
        ANN_ARBOR_PROXY
      end
    end
  end
end
