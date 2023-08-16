class SessionsController < ApplicationController
  def create
    uniqname = request.env["omniauth.auth"]["nickname"]
    puts uniqname
  end
end
