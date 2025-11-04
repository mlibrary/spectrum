module Spectrum
  module Config
    class CSLAggregator

      def initialize
        @fields = {}
      end

      def merge!(value)
        value.each_pair do |key, val|
          next if val.empty?
          if @fields.has_key?(key) && Array === @fields[key]
            @fields[key] = @fields[key] + [val].flatten.compact
          else
            @fields[key] = val
          end
        end
        self
      end

      def spectrum
        {
          uid: 'csl',
          value: @fields,
          name: 'CSL',
          value_has_html: true
        }
      end
    end
  end
end
