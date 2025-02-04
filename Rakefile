# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require "bundler"
Bundler.require

File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

Rake.add_rakelib 'lib/tasks'
