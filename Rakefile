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
  version = if args.version == 'latest'
   HTTParty.get('http://api.github.com/repos/mlibrary/search/releases/latest').parsed_response['tag_name']
  else
    args.version
  end
  url = Shellwords.escape("https://github.com/mlibrary/search/releases/download/#{version}/search-#{args.flavor}.tar.gz")
  pub = Shellwords.escape(File.join(Rails.root, 'public'))
  strip = '--strip-components=1'
  xform = "'--transform=s%search/index.html%search/app.html%'"
  puts "Deploying Search UI #{version} for #{args.flavor}"
  system("wget -O - -q #{url} | tar -xzf - -C #{pub} #{xform} #{strip}")
end

namespace 'assets' do
  namespace 'precompile' do
    desc "Download profile photos"
    task :profile_photos do
      puts "Downloading profile photos ..."
      HTTParty.get('https://cms.lib.umich.edu/api/solr/staff').parsed_response.each do |profile|
        url_string = profile.dig('field_user_photo_display', 0, 'url')
        next unless url_string
        next if url_string.empty?
        url_parsed = URI(url_string)
        dest_file = CGI.unescape('public' + '/photos' + url_parsed.path)
        FileUtils.mkdir_p(File.dirname(dest_file))
        Down.download(url_string, destination: dest_file)
        FileUtils.chmod('ug=rw,o=r', dest_file)
      end
      puts "Finished downloading profile photos"
    end

    desc "Build Search Front End"
    task :search do

      if ENV.fetch('SPECTRUM_BUILDS_SEARCH', false)
        search_branch = ENV['SPECTRUM_SEARCH_GIT_BRANCH'] || 'master'
        pride_branch = ENV['SPECTRUM_PRIDE_GIT_BRANCH'] || 'master'

        system("chmod g-s tmp") || abort("Couldn't fix permissions")
        system('rm -rf tmp/search') || abort('Unable to remove existing search directory')
        system("git clone --branch #{search_branch} --depth 1 https://github.com/mlibrary/search tmp/search") ||
          abort("Couldn't clone search")

        Bundler.with_clean_env do
          Dotenv.load
          system('(cd tmp/search && npm install --no-progress --legacy-peer-deps && npm run build)') ||
            abort("Couldn't build search front end")
        end
        system("chmod g+s tmp") ||
          abort("Couldn't fix permissions")
        system('mv tmp/search/build/index.html tmp/search/build/app.html') ||
          abort("Couldn't rename index to app")
        system('(cd tmp/search/build && tar cf - . ) | (cd public && tar xf -)') ||
          abort("Couldn't copy build to public directory")
      end
      exit 0
    end
  end
end
task :"assets:precompile" => [:"assets:precompile:search", :"assets:precompile:profile_photos"]


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
