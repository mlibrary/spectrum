
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spectrum/json/version'

Gem::Specification.new do |spec|
  spec.name          = 'spectrum-json'
  spec.version       = Spectrum::Json::VERSION
  spec.authors       = ['bertrama']
  spec.email         = ['bertrama@umich.edu']

  spec.summary       = 'TO DO: Write a short summary, because Rubygems requires one.'
  spec.description   = 'TO DO: Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/mlibrary/spectrum-json'

  spec.files         = Dir.glob('{*.*,{lib,app,bin}/**/*.*}').reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TO DO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coveralls', '~> 0.8.21'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'quality', '~> 20.1.0'
  spec.add_development_dependency 'bigdecimal', '~> 1.3.4'
  spec.add_development_dependency 'rerun'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'pry-byebug'



  spec.add_dependency 'alma_rest_client', '~> 2.0.0'
  spec.add_dependency "rake", ">= 12.3.3"
  spec.add_dependency 'activesupport'
  spec.add_dependency 'json-schema'
  spec.add_dependency 'lru_redux'
  spec.add_dependency 'marc'
  spec.add_dependency 'execjs'
  spec.add_dependency 'rsolr'
  spec.add_dependency 'httparty'
  spec.add_dependency 'dotenv'

end
