# frozen_string_literal: true
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

require 'bundler/gem_tasks'

tasks = [:build]
begin
  require 'rspec'
  require 'rspec/core/rake_task'
  require 'quality/rake/task'
  RSpec::Core::RakeTask.new(:spec)
  Quality::Rake::Task.new do |t|
    t.verbose = true
  end
  tasks.unshift(:spec)
  # Disabled until we can focus in improving code quality.
  # tasks << :quality
rescue LoadError => e
  e
end

task default: tasks
