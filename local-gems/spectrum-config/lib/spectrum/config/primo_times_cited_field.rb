# frozen_string_literal: true

module Spectrum
  module Config
    class PrimoTimesCitedField < Field
      type 'primo_times_cited'

      def initialize_from_instance(i)
        super
        @fields = i.fields
      end

      def initialize_from_hash(args, config = {})
        super
        @fields = args['fields']
      end

      def value(data, request = nil)
        # I haven't seen the data from the Primo API yet.
        return nil
        fields.map do |field|
          hsh = {'name' => field['name']}
          if (count = [data.src[field['count']]].flatten.first)
            hsh['count'] = count
            hsh['text']  = "#{field['name']}: #{count}"
            if (href = [data.src[field['href']]].flatten.first)
              hsh['href'] = if request.respond_to?(:proxy_prefix)
                request.proxy_prefix + href
              else
                href
              end
            end
          else
            hsh = nil
          end
          hsh
        end.compact
      end
    end
  end
end
