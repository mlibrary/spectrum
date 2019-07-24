#!/user/bin/env ruby
#

require 'simple_solr_client'
require 'yaml'
require 'erb'

TESTS = [
  'in the heat of the night',
  'heat night',
  'Aleister & Adolf',
  'Archives American Art',
  'Discrete & Computational Geometry',
  'Dance in America: A Reader\'s Anthology',
  '"Dance in America: A Reader\'s Anthology"',
  'Proceedings / Electronic Components & Technology Conference ieee',
  'Proceedings / Electronic Components & Technology Conference',
  'Users Guide to the Medical Literature',
  'The White Mountains',
  'The White Mountain',
  'White Mountains Christopher',
  'White Mountain Christopher',
  'horowitz artists in exile',
  'horowitz artist in exile',
  "d'arms romans on the bay of naples",
  'treggiari roman marriage',
  'music discourse Nattiez',
  'Dynamics of Structures Chopra',
  'pollack george gershwin',
  'Images of Women in Chinese Thought and Culture',
  '"American Victories"',
  'Compact Memory - dem Wissenschaftsportal für Jüdische Studien',
  'Compact Memory dem Wissenschaftsportal für Jüdische Studien',
  'JAMA: Journal of the American Medical Association',
  'Journal of the American Medical Association',
  '"Shakespeare Performed: Essays in Honor of R. A. Foakes"',
  'Shakespeare Performed: Essays in Honor of R. A. Foakes',
  'American Journal of Archaeology',
  'Early American Studies',
  'Rethinking Economic Policy for Social Justice (Economics as Social Theory)',
  'Robert Alter Biblical Narrative',
  'Quantum optics : an introduction',
  'science',
  'nature',
]

def get(query, overrides={}, rows: 5)
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
    'rows' => rows,
    'qt'   => 'edismax',
  }



  args = default_args.merge(overrides).merge({'q' => query, 'qq' => %Q("#{query}")})
  %w[qf pf mm tie ps pf2 ps2 pf3 ps3 bq boost].each {|k| args[k] = params[k] unless params[k].nil?}

  # require 'pp'; pp args; puts; puts;
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
  # require 'pp'; pp result
  result['response']['docs'].each_with_index do |h,i|
    puts basics(h, i)
    puts
  end
end

def gs(query,  overrides={})
  puts "\n\n#{'=' * 50}\n== #{query}\n#{'=' * 50}"
  show(get(query, overrides));
end
