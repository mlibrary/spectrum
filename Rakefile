# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Clio::Application.load_tasks

Rake::Task['assets:precompile'].enhance do
  search_branch = if File.exists?('config/ui-version.txt')
    Shellwords.escape(IO.read('config/ui-version.txt').strip)
  else
    'master'
  end

  pride_branch = if File.exists?('config/pride-version.txt')
    Shellwords.escape(IO.read('config/pride-version.txt').strip)
  else
    'master'
  end

  system('rm -rf tmp/search') || abort('Unable to remove existing search directory')
  system("git clone --branch #{search_branch} --depth 1 https://github.com/mlibrary/search tmp/search") || abort("Couldn't clone search")
  Bundler.with_clean_env do
    system("sed -e 's%pride.git.*\"%pride.git##{pride_branch}\"%' -i '' tmp/search/package.json")
    system('(cd tmp/search && bundle exec npm install --no-progress && bundle exec npm run build)') || abort("Couldn't build search front end")
  end
  system('(cd tmp/search/build && tar cf - . ) | (cd public && tar xf -)') || abort("Couldn't copy build to public directory")
  system('mv public/index.html public/app.html') || abort("Couldn't rename index to app")
end


# Doing this lets us test by just typing "rake", but that also means
# rake will re-initialize the test db every time.
# This is annoying, since we need a library_hours table synced up with
# production data to validate tests.  
# So, omit this, run 'rspec' instead of 'rake'.
# task :default  => :spec


# This bit is for working with a CI server (e.g., Jenkins)
# # https://github.com/nicksieger/ci_reporter
# # To use CI::Reporter, simply add one of the following lines to your Rakefile:
# # 
# require 'ci/reporter/rake/rspec'     # use this if you're using RSpec
# # require 'ci/reporter/rake/cucumber'  # use this if you're using Cucumber
# # require 'ci/reporter/rake/spinach'   # use this if you're using Spinach
# # require 'ci/reporter/rake/test_unit' # use this if you're using Test::Unit
# # require 'ci/reporter/rake/minitest'  # use this if you're using Ruby 1.9 or minitest
