namespace 'assets' do
  desc "Assets:Precompile"
  task :precompile do
  end
  namespace 'precompile' do
    desc "Download profile photos"
    task :profile_photos do
      if ENV.fetch('SPECTRUM_BUILDS_SEARCH', false)
        puts "Downloading profile photos ..."
        HTTParty.get('https://cms.lib.umich.edu/api/solr/staff').parsed_response.each do |profile|
          url_string = profile.dig('field_user_photo_display', 0, 'url')
          next unless url_string
          next if url_string.empty?
          url_parsed = URI(url_string)
          dest_file = CGI.unescape('public' + '/photos' + url_parsed.path)
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
