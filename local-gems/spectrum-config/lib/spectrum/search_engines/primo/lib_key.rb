module Spectrum
  module SearchEngines
    module Primo
      class LibKey
        attr_accessor :data

        def self.for_data(config, type, data)
          return nil unless data
          url = config['host'] + "/public/v1/libraries/#{config['library_id']}/articles/#{type}/#{CGI.escape(data)}"
          headers = {'Authorization' => "Bearer #{config['key']}"}
          response = begin
            HTTParty.get(url, headers: headers)
          rescue Net::OpenTimeout
            ActiveSupport::Notifications.instrument("open_timeout.spectrum_search_engine", source: "libkey")
            nil
          end
          return nil unless response.code == 200
          return nil unless response['data']
          self.new(response['data'])
        end

        def self.for_nothing
          self.new({})
        end

        def initialize(data)
          @data = data
        end

        def has_key?(key)
          data.has_key?(key)
        end

        def [](key)
          return data[key]
        end
      end
    end
  end
end

