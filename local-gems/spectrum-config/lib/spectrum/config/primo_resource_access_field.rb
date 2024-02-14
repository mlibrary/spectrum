require 'htmlentities'

module Spectrum
  module Config
    class PrimoResourceAccessField < Field
      type 'primo_resource_access'

      attr_reader :caption, :headings, :caption_link, :notes, :name, :link_text, :openurl_root, :proxy_prefix

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
        @headings = i.headings
        @caption = i.caption
        @caption_link = i.caption_link
        @link_text = i.link_text
        @openurl_root = i.openurl_root
        @proxy_prefix = i.proxy_prefix
      end

      def initialize_from_hash(args, config = {})
        super
        @name = args['name']
        @notes = args['notes']
        @headings = args['headings']
        @caption = args['caption']
        @caption_link = args['caption_link']
        @link_text = args['link_text']
        @openurl_root = args['openurl_root']
        @proxy_prefix = args['proxy_prefix']
      end

      def value(data, request = nil)

        extra_headings = []

        url = if data.link_to_resource?
          proxy_prefix + URI::encode_www_form_component(data.link_to_resource)
        else
          "#{openurl_root}?#{data.openurl}"
        end

        description = if data.fulltext?
          FULLTEXT
        else
          CITATION_ONLY
        end

        rows = []

        full_text_file = data['fullTextFile']
        if full_text_file && ! full_text_file.empty?
          rows << [
            {href: full_text_file, text: 'View PDF', previewEligible: true},
            FULLTEXT,
          ] + report_a_libkey_problem(data)
        end

        rows << [
          {href: url, text: link_text, previewEligible: true},
          description
        ] + report_a_problem(data)

        return nil if rows.nil? || rows.empty?
        {
          caption: caption,
          headings: headings + report_a_problem_heading(data),
          captionLink: caption_link,
          notes: notes,
          name: name,
          rows: rows,
          preExpanded: true,
          type: 'electronic',
        }.delete_if { |k,v| v.nil? }
      end

      def report_a_libkey_problem(data)
        [{
          html: 'Full text link not working? ' +
             "<a href=\"#{HTMLEntities.new.encode(report_a_libkey_problem_url(data))}\">Report a problem.</a>"
        }]
      end

      def report_a_problem(data)
        if data.respond_to?(:fulltext?) && data.fulltext?
          [{
            html: 'Full text link not working? ' +
               "<a href=\"#{HTMLEntities.new.encode(report_a_problem_url(data))}\">Report a problem.</a>"
          }]
        else
          []
        end
      end


      def report_a_libkey_problem_url(data)
        URI::HTTPS.build(
          scheme: 'https',
          host: 'umich.qualtrics.com',
          path: '/jfe/form/SV_2broDMHlZrBYwJL',
          query: {
            DocumentID: "https://search.lib.umich.edu/primo/record/#{data['id']}",
            LinkModel: 'unknown',
            ReportSource: 'ArticlesSearch-LibKey-GoToPDF',
            utm_source: 'library-search'
          }.to_query
        ).to_s
      end

      def report_a_problem_url(data)
        URI::HTTPS.build(
          scheme: 'https',
          host: 'umich.qualtrics.com',
          path: '/jfe/form/SV_2broDMHlZrBYwJL',
          query: {
            DocumentID: "https://search.lib.umich.edu/primo/record/#{data['id']}",
            LinkModel: 'unknown',
            ReportSource: 'ArticlesSearch',
            utm_source: 'library-search'
          }.to_query
        ).to_s
      end

      def report_a_problem_heading(data)
        if data.respond_to?(:fulltext?) && data.fulltext?
          ['Improving access']
        else
          []
        end
      end

    end
  end
end
