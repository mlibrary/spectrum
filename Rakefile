# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require "bundler"
ENV["ALMA_API_HOST"] ||= ""
Bundler.require
require "rubygems/package"

File.expand_path("lib", __dir__).tap do |libdir|
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
end

Spectrum::Json.configure(__dir__, ENV["RAILS_RELATIVE_URL_ROOT"])

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
  pub = Shellwords.escape(File.join(__dir__, 'public'))
  strip = '--strip-components=1'
  xform = "'--transform=s%search/index.html%search/app.html%'"
  puts "Deploying Search UI #{version} for #{args.flavor}"
  system("wget -O - -q #{url} | tar -xzf - -C #{pub} #{xform} #{strip}")
end

namespace 'assets' do
  desc "Assets:Precompile"
  task :precompile do
  end
  namespace 'precompile' do
    desc "Download cached profile photos"
    task :cached_profile_photos do
      profile_photos = Faraday.get("http://cached-photos/profile-photos.tar")
      # From https://stackoverflow.com/questions/34358926/how-to-extract-tar-file
      Gem::Package::TarReader.new(StringIO.new(profile_photos.body)) do |tar|
        tar.each do |entry|
          if entry.file?
            FileUtils.mkdir_p(File.dirname(entry.full_name))
            File.open(entry.full_name, "wb") do |file|
              file.write(entry.read)
            end
            File.chmod(entry.header.mode, entry.full_name)
          end
        end
      end
    end

    desc "Download profile photos"
    task :profile_photos do
      photo_dir = ENV.fetch("SPECTRUM_PHOTO_DIR", "public/photos")
      if ENV.fetch('SPECTRUM_BUILDS_SEARCH', false)
        puts "Downloading profile photos ..."
        HTTParty.get('https://cms.lib.umich.edu/api/solr/staff').parsed_response.each do |profile|
          url_string = profile.dig('field_user_photo_display', 0, 'url')
          next unless url_string
          next if url_string.empty?
          url_parsed = URI(url_string)
          dest_file = photo_dir + CGI.unescape(url_parsed.path)
          next if File.exist?(dest_file)
          FileUtils.mkdir_p(File.dirname(dest_file))
          retries = 3
          begin
            Down.download(url_string, destination: dest_file)
            FileUtils.chmod('ug=rw,o=r', dest_file)
          rescue
            retries -= 1
            retry if retries > 0
            raise
          end
        end
        puts "Finished downloading profile photos"
      end
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
task :"assets:precompile" => [:"assets:precompile:search"]
Rake::Task['assets:precompile:search'].enhance ['assets:precompile:profile_photos']

