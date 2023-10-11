# frozen_string_literal: true
require 'htmlentities'

module Spectrum
  module Config
    class SummonResourceAccessField < Field
      type 'summon_resource_access'

      attr_reader :model_field, :openurl_root, :openurl_field, :direct_link_field,
        :name, :notes, :headings, :caption, :caption_link

      FULLTEXT = {
        text: 'Full text available',
        intent: 'success',
        icon: 'check_circle',
      }

      CITATION_ONLY = {
        text: 'Citation only',
        intent: 'error',
        icon: 'error',
      }

      def initialize_from_instance(i)
        super
        @name = i.name
        @notes = i.notes
        @caption = i.caption
        @headings = i.headings
        @model_field = i.model_field
        @caption_link = i.caption_link
        @openurl_root = i.openurl_root
        @openurl_field = i.openurl_field
        @direct_link_field = i.direct_link_field
      end

      def initialize_from_hash(args, config)
        super
        @name = args['name']
        @notes = args['notes']
        @caption = args['caption']
        @headings = args['headings']
        @model_field = args['model_field']
        @caption_link = args['caption_link']
        @openurl_root = args['openurl_root']
        @openurl_field = args['openurl_field']
        @direct_link_field = args['direct_link_field']
      end

      def value(data, request = nil)
        return nil unless data
        return nil if data.respond_to?(:empty?) && data.empty?
        href = if [data.src[@model_field]].flatten(1).first == 'OpenURL'
          @openurl_root + '?' + data.send(@openurl_field).gsub(/%requestingapplication%/, '')
        else
          data.send(@direct_link_field)
        end
        {
          headings: headings + report_a_problem_heading(data),
          caption: caption,
          captionLink: caption_link,
          notes: notes,
          name: name,
          rows: [
            [
              {href: href, text: 'Go to item', previewEligible: true},
              description(data),
            ] + report_a_problem(data),
          ],
          preExpanded: true,
          type: 'electronic',
        }.delete_if { |k,v| v.nil? }
      end

      def report_a_problem(data)
        if data.respond_to?(:fulltext) && data.fulltext
          [{
            html: 'Full text link not working? ' +
               "<a href=\"#{HTMLEntities.new.encode(report_a_problem_url(data))}\">Report a problem.</a>"
          }]
        else
          []
        end
      end

      def report_a_problem_url(data)
        URI::HTTPS.build(
          scheme: 'https',
          host: 'umich.qualtrics.com',
          path: '/jfe/form/SV_2broDMHlZrBYwJL',
          query: {
            DocumentID: "https://search.lib.umich.edu/articles/record/#{data.id}",
            LinkModel: 'unknown',
            ReportSource: 'ArticlesSearch',
            utm_source: 'library-search'
          }.to_query
        ).to_s
      end

      def report_a_problem_heading(data)
        if data.respond_to?(:fulltext) && data.fulltext
          ['Improving access']
        else
          []
        end
      end

      def description(data)
        if data.respond_to?(:fulltext) && data.fulltext
          FULLTEXT
        else
          CITATION_ONLY
        end
      end
    end
  end
end
