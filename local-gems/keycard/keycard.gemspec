
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "keycard/version"

Gem::Specification.new do |spec|
  spec.name    = "keycard"
  spec.version = Keycard::VERSION
  spec.authors = ["Noah Botimer", "Aaron Elkiss"]
  spec.email   = ["botimer@umich.edu", "aelkiss@umich.edu"]
  spec.license = "BSD-3-Clause"

  spec.summary = <<~SUMMARY
    Keycard provides authentication support and user/request information,
    especially in Rails applications.
  SUMMARY
  spec.homepage = "https://github.com/mlibrary/keycard"

  spec.files = [
    ".envrc",
    ".gitignore",
    ".rspec",
    ".rubocop.yml",
    ".travis.yml",
    "Gemfile",
    "LICENSE.md",
    "README.md",
    "Rakefile",
    "bin/console",
    "bin/setup",
    "db/migrations/1_create_tables.rb",
    "keycard.gemspec",
    "lib/keycard.rb",
    "lib/keycard/db.rb",
    "lib/keycard/institution_finder.rb",
    "lib/keycard/rack.rb",
    "lib/keycard/rack/inject_attributes.rb",
    "lib/keycard/rack/require_institution.rb",
    "lib/keycard/railtie.rb",
    "lib/keycard/request_attributes.rb",
    "lib/keycard/version.rb",
    "lib/keycard/yaml/institution.rb",
    "lib/keycard/yaml/institution_finder.rb",
    "lib/tasks/migrate.rake",
  ]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "deep_merge"
  spec.add_dependency "mysql2"
  spec.add_dependency "rack"
  spec.add_dependency "sequel"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.52"
  spec.add_development_dependency "rubocop-rails", "~> 1.1"
  spec.add_development_dependency "rubocop-rspec", "~> 1.16"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "yard", "~> 0.9"
end
