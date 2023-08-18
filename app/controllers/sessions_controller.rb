class SessionsController < ApplicationController
  # JUST FOR TESTING
  skip_before_action :verify_authenticity_token
  def create
    # FIXME: need to add everything as default location when no dest
    username = request.env["omniauth.auth"]["info"]["nickname"]
    session[:username] = username
    query = URI.parse(request.env["omniauth.origin"]).query
    dest = CGI.parse(query)["dest"].first
    redirect_to dest
  end

  def new
  end
end
