# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'json'

Clio::Application.load_tasks

REPO_SPEC = Struct.new(:url, :branch)

REPO_URL_MATCHER = /\A(.+?)(?:#(.+))?\Z/

# Rewrite tmp/search package.json to point to its sister-directory `pride`
# and update package-lock.json so "npm install" will actually use it.
def rewrite_search_package_json(pride_repo_spec)
  pride_dir           = Pathname.new(__dir__).parent + 'pride'
  search_package_json = JSON.load(File.read 'tmp/search/package.json')
  # search_package_json['dependencies']['pride'] = "git+file://#{pride_dir.realpath}##{pride_repo_spec.branch}"
  search_package_json['dependencies']['pride'] = "../pride"
  File.open('tmp/search/package.json', 'w:utf-8') { |f| f.puts search_package_json.to_json }
  puts "Linking in pride from ../pride"
  system('(cd tmp/search && bundle exec "npm --no-progress install ../pride" && cd -)') || abort("Can't update pride")
end

def env_repo_spec(env_var_name)
  if m = REPO_URL_MATCHER.match(ENV[env_var_name])
    REPO_SPEC.new(m[1], m[2] || 'master')
  else
    nil
  end
end

Rake::Task['assets:precompile'].enhance do

  # The env variables can include a branch by ending them with '#branchname'
  # If not, branch names will be pulled from config/ui-version.txt and
  # config/pride-version.txt, as shown below

  search_repo_spec = env_repo_spec('SEARCH_REPO_URL') ||
    REPO_SPEC.new('git@github.com:/mlibrary/search', 'master')

  pride_repo_spec = env_repo_spec('PRIDE_REPO_URL') ||
    REPO_SPEC.new('git@github.com:/mlibrary/pride', 'master')

  if File.exists?('config/pride-version.txt')
    pride_repo_spec.branch = Shellwords.escape(IO.read('config/pride-version.txt').strip)
  end

  if File.exists?('config/ui-version.txt')
    search_repo_spec.branch = Shellwords.escape(IO.read('config/ui-version.txt').strip)
  end

  puts "Cloning `search` from #{search_repo_spec.url}, branch #{search_repo_spec.branch}"
  puts "Cloning `pride` from #{pride_repo_spec.url}, branch #{pride_repo_spec.branch}"

  system('rm -rf tmp/search') || abort('Unable to remove existing search directory')
  system('rm -rf tmp/pride') || abort('Unable to remove existing  pride directory')

  system("git clone --branch #{search_repo_spec.branch} --depth 1 #{search_repo_spec.url} tmp/search") || abort("Couldn't clone search")
  system("git clone --branch #{pride_repo_spec.branch} --depth 1 #{pride_repo_spec.url} tmp/pride") || abort("Couldn't clone pride")
  Bundler.with_clean_env do
    rewrite_search_package_json(pride_repo_spec)
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
