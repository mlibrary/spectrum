#!/user/bin/env ruby
#

require 'simple_solr_client'
require 'yaml'
require 'erb'

def get(query)
  solr_base = ENV['SOLR_URL_BASE'] || 'http://localhost:8025/solr'

  core = SimpleSolrClient::Client.new(solr_base).core('biblio')

  params = YAML.load(ERB.new(File.read('config/foci/mirlyn.yml')).result)['solr_params']

  qf = params['qf']
  pf = params['pf']
  mm = params['mm']
  tie = params['tie']

  default_args = {
    'wt'   => 'json',
    'fl'   => 'score,id,title,author',
    'rows' => 10,
    'qt'   => 'edismax',
  }

  args = default_args.merge({'q' => query, 'pf' => pf, 'qf' => qf, 'mm' => mm, 'tie' => tie})

  result = core.get('select', args)
end

def basics(result_hash, i)
  [
    "%2d. %8.2f %s" % [i+1, result_hash['score'], result_hash['title'].first],
    result_hash['author'].nil? ? nil : (' ' * 13) + result_hash['author'].take(2).join(' | '),
    (' ' * 13) + 'id: ' + result_hash['id']
  ].compact
end

def show(result)
  result['response']['docs'].each_with_index do |h,i|
    puts basics(h, i)
    puts
  end
end

def gs(query)
  show(get(query));
end
