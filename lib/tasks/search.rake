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
