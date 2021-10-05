# frozen_string_literal: true

module Spectrum
  module Json
    class Ris
      TYPES = Hash.new('GEN').merge(
        'book' => 'BOOK',
        'book / ebook' => 'BOOK',
        'journal article' => 'JOUR',
        'publication article' => 'JOUR',
        'trade publication article' => 'JOUR',
        'journal / ejournal' => 'JFULL',
        'journal' => 'JFULL',
        'serial' => 'SER',
        'map' => 'MAP',
        'maps-atlas' => 'MAP',
        'atlas' => 'MAP',
        'ebook' => 'EBOOK',
        'motion picture' => 'VIDEO',
        'video recording' => 'VIDEO',
        'video (blu-ray)' => 'VIDEO',
        'video (dvd)' => 'VIDEO',
        'video (vhs)' => 'VIDEO',
        'video games' => 'VIDEO',
        'streaming video' => 'VIDEO',
        'audio' => 'SOUND',
        'audio recording' => 'SOUND',
        'audio (spoken word)' => 'SOUND',
        'audio cd' => 'SOUND',
        'audio lp' => 'SOUND',
        'streaming audio' => 'SOUND',
        'spoken word recording' => 'SOUND',
        'audio (music)' => 'MUSIC',
        'music' => 'MUSIC',
        'music recording' => 'MUSIC',
        'musical score' => 'MUSIC',
        'music score' => 'MUSIC',
        'sheet music' => 'MUSIC',
        'thesis' => 'THES',
        'student thesis' => 'THES',
        'dissertation' => 'THES',
        'dictionaries' => 'DICT',
        'data file' => 'DBASE',
        'data set' => 'DBASE',
        'computer file' => 'DBASE',
        'cdrom' => 'DBASE',
        'software' => 'DBASE',
        'magazine' => 'MGZN',
        'magazine article' => 'MGZN',
        'newspaper' => 'NEWS',
        'newspaper article' => 'NEWS',
        'encyclopedias' => 'ENCYC',
        'conference' => 'CONF',
        'conference proceeding' => 'CONF',
        'paper' => 'CPAPER',
        'book chapter' => 'CHAP',
        'internet communication' => 'ICOMM',
        'electronic resource' => 'ICOMM',
        'web resource' => 'ICOMM',
        'gen' => 'GEN',
        '*' => 'GEN'
      )

      TAG_ARITY = Hash.new(:single_valued_tag).merge(
        'AU' => :multi_valued_tag,
        'KW' => :multi_valued_tag,
        'M1' => :multi_valued_tag,
        'N1' => :multi_valued_tag,
        'PB' => :multi_valued_tag,
        'UR' => :multi_valued_tag,
      )

      class << self
        attr_accessor :fields
        def configure!(_config)
          self.fields = %i[
            type
            id
            title
            author
            publisher
            publication_year
            publication_place
            publication
            issue
            volume
            doi
            sn
            url
            sp
            ep
            er
          ]
        end

        def publication(item)
          single_valued(item, 'T2', 'publication_title')
        end

        def issue(item)
          single_valued(item, 'IS', 'issue')
        end

        def volume(item)
          single_valued(item, 'VL', 'volume')
        end

        def doi(item)
          single_valued(item, 'DO', 'doi')
        end

        def url(item)
          field(item, 'links').map do |link|
            link.find { |attr| attr['uid'] == 'href' }
          end.compact.map do |item|
            "L2  - #{item['value']}"
          end.join("\n")
        end

        def id(item)
          single_valued(item, 'ID', 'id')
        end

        def sn(item)
          %w[issn isbn eisbn eissn].each_with_object([]) do |uid, acc|
            acc << multi_valued(item, 'SN', uid)
          end.compact.reject(&:empty?).join("\n")
        end

        def cn(item)
          multi_valued(item, 'CN', 'callnumber')
        end

        def sp(item)
          single_valued(item, 'SP', 'start_page')
        end

        def ep(item)
          single_valued(item, 'EP', 'end_page')
        end

        def message(items)
          items.map { |item| ris(item) }.join("\n\n\n")
        end

        def title(item)
          multi_valued(item, 'TI', 'title')
        end

        def author(item)
          multi_valued(item, 'AU', 'author')
        end

        def publisher(item)
          multi_valued(item, 'PB', 'publisher')
        end

        def publication_year(item)
          multi_valued(item, 'PY', 'published_year')
        end

        def publication_place(item)
          multi_valued(item, 'PP', 'place_of_publication')
        end

        def ris(item)
          ret = []
          ret << type(item)
          ret << db(item)
          ret << 'DP  - University of Michigan Library'
          ret << "Y2  - #{DateTime.now.strftime('%Y-%m-%d')}"
          datastore = item.find {|el| el[:uid] == 'datastore'}[:value]
          fields = ::Spectrum::Json.foci[datastore].fields
          item.each do |field|
            next unless field_def = fields.by_uid(field[:uid])
            next unless field_def.ris
            field_def.ris.each do |tag|
              ret += ris_line(tag, field[:value])
            end
          end
          ret << er(item)
          ret.compact.reject(&:empty?).uniq.join("\r\n")
        end

        def ris_line(tag, value, tag_arity = TAG_ARITY)
          send(tag_arity[tag], tag, value)
        end

        def single_valued_tag(tag, value)
          return [] unless tag && value
          value = value.to_s unless value.respond_to?(:empty?)
          return [] if value.empty? || tag.empty?
          value = [value].flatten.first
          if Hash === value
            if value.has_key?(:value)
              value = [value[:value]].flatten.first
            else
              return []
            end
          end
          ["#{tag}  - #{value.to_s.gsub(/[\r\n]/, ' ')}"]
        end

        def multi_valued_tag(tag, values)
          return [] unless tag && values
          return [] if tag.empty? || values.empty?
          [values].flatten.map do |value|
            if Hash === value
              if value.has_key?(:value)
                value = value[:value]
              else
                value = []
              end
            end
            [value].flatten.map do |val|
              if val.empty?
                nil
              else
                "#{tag}  - #{val.to_s.gsub(/[\r\n]/, ' ')}"
              end
            end.compact
          end.flatten.compact
        end

        def db(item)
          case field(item, 'datastore').first
          when 'mirlyn'
            'DB  - U-M Catalog Search'
          when 'primo', 'articles', 'articlesplus'
            'DB  - U-M Articles Search'
          when 'databases'
            'DB  - U-M Database Search'
          when 'journals', 'onlinejournals'
            'DB  - U-M Online Journals Search'
          when 'website'
            'DB  - U-M Library Website Search'
          end
        end

        def type(item)
          case field(item, 'datastore').first
          when 'databases'
            'TY  - DBASE'
          when 'journals', 'onlinejournals'
            'TY  - JFULL'
          when 'website'
            'TY  - ICOMM'
          else
            single_valued(item, 'TY', 'format', 'gen', TYPES)
          end
        end

        def er(_item)
          'ER  -'
        end

        def single_valued(item, tag, uid, default = nil, map = nil)
          value = field(item, uid).first || default
          value = map[value.downcase] if map
          return nil unless value
          "#{tag}  - #{value}"
        end

        def multi_valued(item, tag, uid)
          field(item, uid).map { |value| "#{tag}  - #{value}" }.join("\n")
        end

        def field(message, uid, glue = nil)
          if glue
            field_value(message, uid).join(glue)
          else
            field_value(message, uid)
          end
        end

        def field_value(message, uid)
          values = message.find { |field| field[:uid] == uid }
          return Array(values[:value]) if values
          []
        end
      end
    end
  end
end
