source 'https://rubygems.org' do

  # I'm getting deployment errors with capistrano about trying to load pry
  gem 'pry'
  gem 'lograge'

  # Allow dotenv configuration
  gem 'dotenv-rails', require: 'dotenv/rails-now'

  gem 'skylight'
  gem 'net-ldap'
  gem 'twilio-ruby'
  gem 'exlibris-aleph', '~>2.0.4'
  gem 'puma'
  gem 'parslet'
  gem 'execjs', '~> 2.7.0'

  gem 'ipresolver',
    git: 'https://github.com/mlibrary/ipresolver',
    branch: 'master'

  gem 'keycard',
    git: 'https://github.com/bertrama/keycard',
    branch: 'rack-yaml-institution-finder',
    require: ['keycard/rack', 'keycard/yaml/institution_finder']

  gem 'spectrum-config',
    git: 'https://github.com/mlibrary/spectrum-config',
    branch: 'master'

  gem 'spectrum-json',
    git: 'https://github.com/mlibrary/spectrum-json',
    branch: 'master'

  gem 'alma_rest_client',
    git: 'https://github.com/mlibrary/alma_rest_client',
    tag: '1.0.1'

  gem 'mlibrary_search_parser',
    git: 'https://github.com/mlibrary/mlibrary_search_parser',
    branch: 'master'

  gem 'aleph',
    git: 'https://github.com/mlibrary/aleph',
    branch: 'master'
  
  gem 'rails', '~> 4.2.0'

  #  ###  BLACKLIGHT (begin)  ###
  gem 'blacklight', '~>5.3.0'
  gem 'blacklight-marc'
  #  ###  BLACKLIGHT (end)  ###

  gem 'json'

  platforms :mri do
    gem 'therubyracer'
  end

  gem 'httpclient'
  gem 'nokogiri', '>= 1.8.5'

  # HTML replacement language
  gem 'haml'
  gem 'haml-rails'

  # CSS replacement language
  gem 'sass'

  gem 'unicode'
  gem 'summon'
  gem 'cancan'
  gem 'exception_notification'

  # "Rack middleware which cleans up invalid UTF8 characters"
  # gem 'rack-utf8_sanitizer'
  # Use github master branch, to pick up a few new patches.
  # Maybe this will fix one of our outstanding issues:
  #    application#catch_404s (ArgumentError) "invalid %-encoding"
  # We also still have invalid %-encoding w/submitted form fields.
  # This is an open issue at rack-utf8_sanitizer.
  # gem 'rack-utf8_sanitizer', :github => 'whitequark/rack-utf8_sanitizer'
  gem 'rack-utf8_sanitizer', :git => 'https://github.com/whitequark/rack-utf8_sanitizer'

  # gives us jQuery and jQuery-ujs, but not jQuery UI
  # (blacklight_range_limit brings this in anyway - no way to switch to CDN)
  gem 'jquery-rails'
  
  group :assets do
    gem 'sass-rails'
    gem 'coffee-rails'
    gem 'uglifier'
    gem 'bootstrap-sass', ">= 3.4.1"
  end


  # To build slugs for saved-list URLs
  gem 'stringex'

  group :development do
    gem 'rbtrace'
    gem 'pry-byebug', platforms: :mri
    gem 'pry-rails'
    gem 'rerun'
    gem 'quiet_assets'

    platforms :mri do
      gem 'binding_of_caller'
  
      # "A fist full of code metrics"
      gem 'metric_fu'
    end

  end

  group :test, :development do
    gem 'rspec-rails'
  end

  group :test do
    gem 'minitest'

    gem 'factory_girl_rails'

    # Copy Stanford's approach to Solr relevancy testing
    gem 'rspec-solr'

    # pin to old version, or go with newest?
    gem 'capybara'

    # Which Capybara driver for JS support?
    platforms :mri do
      gem 'ruby-prof'
    end
    # dependent on localhost's browser configs

    gem 'launchy'
    gem 'database_cleaner'

    gem 'rb-fsevent'

    # code coverage
    gem 'simplecov'

    # Lock sprockets to 3.x
    gem 'sprockets', '~>3.0'

  end
end
