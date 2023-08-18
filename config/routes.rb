# https://stackoverflow.com/questions/5631145/routing-to-static-html-page-in-public

module ActionDispatch
  module Routing
    class StaticResponder < Endpoint
      attr_accessor :path, :file_handler

      def initialize(path)
        self.path = path
        # Only if you're on Rails 5+:
        # self.file_handler = ActionDispatch::FileHandler.new(
        #  Rails.configuration.paths["public"].first
        # )
        # Only if you're on Rails 4.2:
        self.file_handler = ActionDispatch::FileHandler.new(
          Rails.configuration.paths["public"].first,
          Rails.configuration.static_cache_control
        )
      end

      def call(env)
        env["PATH_INFO"] = @file_handler.match?(path)
        @file_handler.call(env)
      end

      def inspect
        "static('#{path}')"
      end
    end

    class Mapper
      def static(path)
        StaticResponder.new(path)
      end
    end
  end
end

Clio::Application.routes.draw do
  mount Spectrum::Json::Engine => "/spectrum/"
  get "/", to: redirect("/everything", status: 302)
  get "/index.html", to: redirect("/everything", status: 302)
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  get "/auth/openid_connect/callback", to: "sessions#create"
  # get "/login", to: redirect(status: 302) { |params, request|
  # if request.params["dest"] && request.params["dest"].start_with?("/")
  # request.params["dest"]
  # else
  # "/everything"
  # end
  # }
  get "*_", to: static("app.html")
end
