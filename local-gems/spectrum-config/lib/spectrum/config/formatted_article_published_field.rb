# frozen_string_literal: true
module Spectrum
  module Config
    class FormattedArticlePublishedField < Field
      type 'formatted_article_published'

      attr_reader :fields, :pub_title_fields, :volume_field, :issue_field, :ispartof_field, :pages_field

      def initialize_from_instance(i)
        super
        @fields = i.fields
        @pub_title_fields = i.pub_title_fields
        @volume_field = i.volume_field
        @issue_field = i.issue_field
        @ispartof_field = i.ispartof_field
        @pages_field = i.pages_field
      end

      def initialize_from_hash(args, config)
        super
        @pub_title_fields = args['pub_title_fields'] || ['publication_title']
        @volume_field = args['volume_field'] || 'volume'
        @issue_field = args['issue_field'] || 'issue'
        @ispartof_field = args['ispartof_field'] || 'ispartof'
        @pages_field = args['pages_field'] || 'pages'

        @fields = {}
        args['fields'].each_pair do |fname, fdef|
          @fields[fname] = Field.new(
            fdef.merge('id' => SecureRandom.uuid, 'metadata' => {}),
            config
          )
        end
      end

      def value(data, request = nil)
        pub_title = pub_title_fields.map do |pub_title_field|
          @fields[pub_title_field].value(data)
        end.flatten.compact.first
        volume = [@fields[volume_field].value(data)].flatten.first
        issue = [@fields[issue_field].value(data)].flatten.first
        ispartof = [@fields[ispartof_field].value(data)].flatten.first
        pages = [@fields[pages_field].value(data)].flatten.first
        if pages
          if pages.end_with?('-')
            pages = pages[0...-1]
          elsif pages.include?('-')
            pages_list = pages.split(/-/)
            if pages_list[0] == pages_list[1]
              pages = pages_list[0]
            end
          end
          pages_label = pages.include?('-') ? 'pp.' : 'p.'
        end

        ret = []
        ret << pub_title if pub_title && (volume || issue || pages)
        ret << "Vol. #{volume}" if volume
        ret << "Issue #{issue}" if issue
        ret << "#{pages_label} #{pages}" if pages
        ret << ispartof if ret.empty? && ispartof
        ret.join(", ")
      end
    end
  end
end
