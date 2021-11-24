# This file is used by Rack-based servers to start the application.
#ENV['RAILS_RELATIVE_URL_ROOT'] = "/testapp/spectrum"

require ::File.expand_path('../config/environment',  __FILE__)

::BLACKLIGHT_VERBOSE_LOGGING=true

require 'catalog-browse'

map '/browse.css' do
  use CatalogBrowse::BrowseCSS
  run CatalogBrowse
end

map '/catalog/browse' do
  run CatalogBrowse
end

map '/' do
  run Clio::Application
end
