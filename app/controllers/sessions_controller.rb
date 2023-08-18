class SessionsController < ApplicationController
  def create
    username = request.env["omniauth.auth"]["info"]["nickname"]
    session[:username] = username
    query = URI.parse(request.env["omniauth.origin"]).query
    if query.nil? || CGI.parse(query)["dest"].empty?
      redirect_to "/everything"
    else
      redirect_to CGI.parse(query)["dest"].first
    end
  end

  def new
  end

  def destroy
    url = ENV.fetch("REACT_APP_LOGIN_BASE_URL") + params["dest"]
    # adds trailing slash if needed
    url << "/" unless url.end_with?("/")
    reset_session
    redirect_to "https://shibboleth.umich.edu/cgi-bin/logout?#{url}"
  end
end
