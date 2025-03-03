module Spectrum
  module SearchEngines
    module Primo
      class Doc

        attr_reader :data, :extras, :delivery

        def self.for_json(json, position)
          self.new(
            data: json['pnx'],
            extras: json['extras'],
            delivery: json['delivery'],
            position: position
          )
        end

        def initialize(data: {}, extras: {}, delivery: {}, position: 0)
          @data = data
          @extras = extras
          @delivery = delivery
          @data['internal'] = {
            'position' => position,
            'id' => [(data['control'] || {})['recordid']].flatten.first,
            'alt_ids' => [
              data.dig('control', 'recordid'),
              data.dig('control', 'sourcerecordid'),
              data.dig('control', 'originalsourceid'),
              data.dig('control', 'addsrcrecordid'),
            ].compact.flatten,
          }
          @data['libkey'] = {}
        end

        def libkey=(data)
          @data['libkey'] = data
        end

        def fulltext?
          @fulltext ||= !@delivery['availability'].include?('no_fulltext')
        end

        def link_to_resource?
          @is_link_to_resource ||= @delivery['availability'].any? do |availability|
            availability.include?('linktorsrc')
          end
        end


        # Sometimes the link to the resource is already fully formed, others it needs to be constructed
        def link_to_resource
          @link_to_resource ||= get_link_to_resource_from_data || construct_link_to_resource
        end

        # If there's a $$U linktosrc use it
        def get_link_to_resource_from_data
          [@data.dig('links', 'linktorsrc')].flatten.compact.map do |linktorsrc|
            linktorsrc.split('$$').filter do |link|
              link.start_with?('U')
            end.map do |link|
              link[1, link.length]
            end
          end.flatten.first
        end

        # Otherwise look up the link type ($$T for the link), and construct the link
        # These are going to be brittle.  Long term I'll need to look them up and use that.
        def construct_link_to_resource
          case link_type
          when 'naxos_video'
            "https://umich.naxosvideolibrary.com/title/#{sourcerecordid}"
          when 'naxos_music_library', 'naxos_music_libray'
            "https://umich.naxosmusiclibrary.com/catalogue/item.asp?cid=#{sourcerecordid}"
          when 'gale_linking'
            "http://link.galegroup.com/apps/doc/#{sourcerecordid}/#{addsrcrecordid}?sid=primo&u=umuser"
          when 'moazine_linking', 'moazine_article_linking'
            "http://dl.moazine.com/viewer3/index.asp?libraryid=9MtJb2T3nzH3BEvu609VaY52Ca3EA1Y2EWW0&articleid=#{sourcerecordid}&articlepage=1"
          else
            nil
          end
        end

        def addsrcrecordid
          @addsrcrecordid ||= [@data.dig('control', 'addsrcrecordid')].flatten.first
        end

        def sourcerecordid
          @sourcerecordid ||= [@data.dig('control', 'sourcerecordid')].flatten.first
        end

        def link_type
          link_type = [@data.dig('links', 'linktorsrc')].flatten.compact.map do |linktorsrc|
            linktorsrc.split('$$').filter do |link|
              link.start_with?('T')
            end.map do |link|
              link[1, link.length]
            end
          end.flatten.first
        end

        def openurl
          @delivery['almaOpenurl'].sub(/^.*\?/,'')
        end

        def empty?
          false
        end

        def [](key)
          ['control', 'display', 'addata', 'search', 'internal', 'facets', 'libkey'].each do |area|
            if data[area].has_key?(key)
              return data[area][key]
            end
          end
          return nil
        end
      end
    end
  end
end
