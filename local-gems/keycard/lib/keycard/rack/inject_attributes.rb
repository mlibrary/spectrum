# frozen_string_literal: true

require 'deep_merge'
require 'rack/request'
require 'keycard/request_attributes'

module Keycard
  module Rack
    # Rack middleware to inject attributes to the env with deep_merge.
    class InjectAttributes
      attr_reader :app, :finder

      def initialize(app, finder)
        @app = app
        @finder = finder
      end

      def call(env)
        req = ::Rack::Request.new(env)
        attrs = RequestAttributes.new(req, finder: finder).all
        @app.call(env.deep_merge(attrs))
      end
    end
  end
end
