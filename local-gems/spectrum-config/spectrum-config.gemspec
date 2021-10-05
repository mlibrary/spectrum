# coding: utf-8
# frozen_string_literal: true

# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spectrum/config/version'

Gem::Specification.new do |spec|
  spec.name          = 'spectrum-config'
  spec.version       = Spectrum::Config::VERSION
  spec.authors       = ['bertrama']
  spec.email         = ['bertrama@umich.edu']
  spec.summary       = 'Write a short summary. Required.'
  spec.description   = 'Write a longer description. Optional.'
  spec.homepage      = ''
  spec.license       = 'BSD-3-Clause'

  spec.files         = Dir.glob('{*.*,{lib,app,bin}/**/*.*}').reject { |f| f.match(%r{^(test|spec|features)/}) } 
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'marc'
  spec.add_dependency 'htmlentities'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'rails-html-sanitizer'
  spec.add_dependency 'httparty'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'quality'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-lcov', '~> 0.7.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
