# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] = "test"
ENV["APP_ENV"] = "test"
Bundler.require
Spectrum::Json.configure(__dir__, 'http://localhost:3000')

# Prevent database truncation if the environment is production
OmniAuth.config.test_mode = true
