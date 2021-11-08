source 'https://rubygems.org' do

  #slim templates
  gem 'slim'
  # I'm getting deployment errors with capistrano about trying to load pry
  gem 'pry'
  gem 'lograge'

  # Allow dotenv configuration
  gem 'dotenv-rails', require: 'dotenv/rails-now'

  gem 'skylight'
  gem 'net-ldap'
  gem 'twilio-ruby'
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

  gem 'spectrum-config', path: 'local-gems/spectrum-config'

  gem 'spectrum-json', path: 'local-gems/spectrum-json'

  gem 'alma_rest_client',
    git: 'https://github.com/mlibrary/alma_rest_client',
    tag: '1.0.1'

  gem 'mlibrary_search_parser',
    git: 'https://github.com/mlibrary/mlibrary_search_parser',
    branch: 'master'

  gem "callnumber_collation",
    git: "https://github.com/billdueber/callnumber_collation",
    branch: 'main'

  gem 'rails', '~> 4.2.0'

  #  ###  BLACKLIGHT (begin)  ###
  gem 'blacklight', '~>5.3.0'
  gem 'blacklight-marc'
  #  ###  BLACKLIGHT (end)  ###

  gem 'json'

  gem 'httpclient'
  gem 'nokogiri', '>= 1.8.5'

  # HTML replacement language

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
    gem 'simplecov'
    gem 'webmock'
  end

end
