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
        end

        def fulltext?
          @fulltext ||= @delivery['availability'].any? do |availability|
            availability.include?('fulltext')
          end
        end

        def link_to_resource?
          @is_link_to_resource ||= @delivery['availability'].any? do |availability|
            availability.include?('linktorsrc')
          end
        end

        def link_to_resource
          @link_to_resource ||= [@data.dig('links', 'linktorsrc')].flatten.compact.map do |linktorsrc|
            linktorsrc.scan(/\$\$.[^$]*/).filter do |link|
              link.start_with?('$$U')
            end.map do |link|
              link[3, link.length]
            end
          end.flatten.first
        end

        def openurl
          @delivery['almaOpenurl'].sub(/^.*\?/,'')
        end

        def [](key)
          ['control', 'display', 'addata', 'search', 'internal', 'facets'].each do |area|
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
