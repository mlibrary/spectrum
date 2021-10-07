# frozen_string_literal: true
module Spectrum
  module Config
    class FormattedArticlePublishedField < Field
      type 'formatted_article_published'

      attr_reader :fields, :pub_title_field, :volume_field, :issue_field
      def initialize_from_instance(i)
        super
        @fields = i.fields
        @pub_title_field = i.pub_title_field
        @volume_field = i.volume_field
        @issue_field = i.issue_field
      end

      def initialize_from_hash(args, config)
        super
        @pub_title_field = args['pub_title_field'] || 'publication_title'
        @volume_field = args['volume_field'] || 'volume'
        @issue_field = args['issue_field'] || 'issue'
        @fields = {}
        args['fields'].each_pair do |fname, fdef|
          @fields[fname] = Field.new(
            fdef.merge('id' => SecureRandom.uuid, 'metadata' => {}),
            config
          )
        end
      end

      def value(data, request = nil)
        pub_title = [@fields[pub_title_field].value(data)].flatten.first
        volume = [@fields[volume_field].value(data)].flatten.first
        issue = [@fields[issue_field].value(data)].flatten.first

        ret = String.new('')
        ret << pub_title if pub_title
        ret << ' Vol. ' + volume if volume
        ret << ', Issue ' + issue if issue
        ret
      end
    end
  end
end
