# frozen_string_literal: true

require 'htmlentities'

module Spectrum
  module Config
    class TimesCitedField < Field
      type 'times_cited'

      def initialize_from_instance(i)
        super
        @fields = i.fields
      end

      def initialize_from_hash(args, config = {})
        super
        @fields = args['fields']
      end

      def value(data, request = nil)
        encoder = HTMLEntities.new
        fields.map do |field|
          if (count = [data.src[field['count']]].flatten.first)
            if (href = [data.src[field['href']]].flatten.first)
              href = request.proxy_prefix + href if request
              "#{encoder.encode(field['name'])}: <a href='#{encoder.encode(href)}'>#{encoder.encode(count)}</a>"
            else
              "#{encoder.encode(field['name'])}: #{encoder.encode(count)}"
            end
          else
            nil
          end
        end.compact.join('; ')
      end
    end
  end
end
