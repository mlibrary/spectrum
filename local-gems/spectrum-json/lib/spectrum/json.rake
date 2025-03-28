require 'csv'
require 'net/http'

namespace :spectrum do
  namespace :json do
    desc "Parse search strings into json objects"
    task :parse, [:file, :column] do |task, args|
      raise "TODO: Convert this to using the mlibrary_search_parser."
#      underscore = Net::HTTP.get(URI.parse('https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.9.1/underscore.js')).encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
#      pride      = Net::HTTP.get(URI.parse('https://raw.githubusercontent.com/mlibrary/pride/master/pride.execjs.js')).encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
#      parser     = 'Pride.Parser.parse'
#      context    = ExecJS.compile(underscore + pride)
#
#      col = args[:column].to_i
#      tsv = CSV.read(args[:file], {col_sep: "\t", liberal_parsing: true, headers: true})
#      tsv.each do |row|
#        raw_query = row[col]
#        parsed_query = begin
#          context.call(parser, raw_query)
#        rescue
#          context.call(parser, '"' + raw_query.gsub(/"/, '') + '"')
#        end
#        puts CSV.generate_line([raw_query, parsed_query.to_json], {col_sep: "\t", liberal_parsing: true, headers: true})
#      end
    end

    desc "Search parsed search strings against all datastores publicized in spectrum"
    task :search, [:file, :datastore, :count] => [:environment] do |task, args|

      raise "TODO: Convert this to use the sinatra-based structure."

#      tsv = CSV.read(args[:file], {col_sep: "\t", liberal_parsing: true})
#      tsv.each do |row|
#        controller = JsonController.new
#        focus = Spectrum::Json.foci[args[:datastore]]
#        source = focus.source
#
#        request = OpenStruct.new(
#          parameters: {
#            uid: args[:datastore],
#            focus: args[:datastore],
#            source: source,
#            start: 0,
#            count: args[:count].to_i,
#            facets: {},
#            sort: 'relevance',
#            settings: {},
#            query: row[1],
#          },
#          post?: true,
#          raw_post: {
#            uid: args[:datastore],
#            focus: args[:datastore],
#            source: source,
#            start: 0,
#            count: args[:count].to_i,
#            facets: {},
#            sort: 'relevance',
#            settings: {},
#            query: row[1],
#          }.to_json,
#          env: {'SERVER_NAME' => 'search.lib.umich.edu'}
#        )
#
#        controller.request = request
#        controller.init
#
#        ret = controller.instance_eval do
#          @request      = Spectrum::Request::DataStore.new(request, @focus)
#          @new_request  = Spectrum::Request::DataStore.new(request, @focus)
#          @datastore    = Spectrum::Response::DataStore.new(this_datastore)
#          @specialists  = OpenStruct.new(spectrum: nil)
#          @response     = Spectrum::Response::RecordList.new(fetch_records, @request)
#          search_response
#        end
#
#        raw_query = row[0]
#        parsed_query = row[1]
#
#        records = ret[:response].map do |record|
#          [record[:uid], [record[:names]].flatten.first]
#        end.flatten
#
#        puts CSV.generate_line(
#          row + [ret[:total_available]] + records,
#          {col_sep: "\t", liberal_parsing: true}
#        )
#      end
    end
  end
end
