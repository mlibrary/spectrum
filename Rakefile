# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

module Clio
  def self.under_rake!
    @under_rake = true
  end
end
Clio.under_rake!

require File.expand_path('../config/application', __FILE__)
require 'rake'

# Load up .env file if we've got one
require 'dotenv'
Dotenv.load

Clio::Application.load_tasks

desc "Install versioned/flavored Search UI"
task :search, [:version, :flavor] do |t, args|
  unless args.version && args.flavor
    puts "Cowardly refusing to deploy Search UI without 'version' and 'flavor'"
    next
  end
  url = Shellwords.escape("https://github.com/mlibrary/search/releases/download/#{args.version}/search-#{args.flavor}.tar.gz")
  pub = Shellwords.escape(File.join(Rails.root, 'public'))
  strip = '--strip-components=1'
  xform = "'--transform=s%search/index.html%search/app.html%'"
  puts "Deploying Search UI #{args.version} for #{args.flavor}"
  system("wget -O - -q #{url} | tar -xzf - -C #{pub} #{xform} #{strip}")
end

Rake::Task['assets:precompile'].enhance do

  search_branch = ENV['SPECTRUM_SEARCH_GIT_BRANCH'] || 'master'
  pride_branch = ENV['SPECTRUM_PRIDE_GIT_BRANCH'] || 'master'

  system("chmod g-s tmp") || abort("Couldn't fix permissions")
  system('rm -rf tmp/search') || abort('Unable to remove existing search directory')
  system("git clone --branch #{search_branch} --depth 1 https://github.com/mlibrary/search tmp/search") || abort("Couldn't clone search")

  #search_package = 'tmp/search/package.json'
  #File.read(search_package).tap{|contents| File.open(search_package, 'w:utf-8') {|f| f.puts contents.gsub(/pride\.git/, "pride.git\##{pride_branch}")}}
    
  Bundler.with_clean_env do
    Dotenv.load
    system('(cd tmp/search && npm install --no-progress && npm run build)') || abort("Couldn't build search front end")
  end
  system("chmod g+s tmp") || abort("Couldn't fix permissions")

  system('mv tmp/search/build/index.html tmp/search/build/app.html') || abort("Couldn't rename index to app")
  system('(cd tmp/search/build && tar cf - . ) | (cd public && tar xf -)') || abort("Couldn't copy build to public directory")

  # Temporary addition: build an alt search interface.
  # We know we want this to use the master branch of pride.
  if pride_branch != 'master'
    system('rm -rf tmp/search.alt') || abort('Unable to remove existing search directory')
    system("git clone --branch #{search_branch} --depth 1 https://github.com/mlibrary/search tmp/search.alt") || abort("Couldn't clone search")
    Bundler.with_clean_env do
      Dotenv.load
      system('(cd tmp/search.alt && npm install --no-progress && npm run build)') || abort("Couldn't build search front end")
    end
    system('mv tmp/search.alt/build/index.html tmp/search.alt/build/app.html') || abort("Couldn't rename index to app")
  end
end if (`which npm` && $?.success?)


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
