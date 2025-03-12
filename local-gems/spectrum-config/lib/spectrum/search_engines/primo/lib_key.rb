module Spectrum
  module SearchEngines
    module Primo
      class LibKey
        attr_accessor :data

        def self.for_data(config, type, data)
          return for_nothing unless data
          url = config["host"] + "/public/v1/libraries/#{config["library_id"]}/articles/#{type}/#{CGI.escape(data)}"
          headers = {"Authorization" => "Bearer #{config["key"]}"}
          response = begin
            HTTParty.get(url, headers: headers, open_timeout: 0.5)
          rescue => e
            ActiveSupport::Notifications.instrument("libkey_exception.spectrum_search_engine_primo", source_id: "libkey", type: type, data: data, exception: e)
            return for_nothing
          end
          return for_nothing unless response.code == 200
          return for_nothing unless response["data"]
          new(response["data"])
        end

        def self.for_nothing
          new({})
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

