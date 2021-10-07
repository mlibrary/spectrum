# frozen_string_literal: true
module Spectrum
  module Config
    class Credentials
      attr_accessor :type, :token, :account, :service,
                    :subject, :text_header, :text_footer, :html_header, :html_footer
      def initialize(data)
        data ||= {}
        self.type = data['type']
        self.token = data['token']
        self.account = data['account']
        self.service = data['service']

        self.subject = data['subject']
        self.text_header = data['text_header']
        self.text_footer = data['text_footer']
        self.html_header = data['html_header']
        self.html_footer = data['html_footer']
      end
    end
  end
end
