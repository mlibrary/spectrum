module Spectrum
  module Json
    class App < Sinatra::Base
      module Common
        AA_ADDRESSES = [
          IPAddr.new("35.0.0.0/16"),
          IPAddr.new("35.1.0.0/16"),
          IPAddr.new("35.2.0.0/16"),
          IPAddr.new("35.3.0.0/16"),
          IPAddr.new("67.194.0.0/16"),
          IPAddr.new("141.211.0.0/16"),
          IPAddr.new("141.212.0.0/16"),
          IPAddr.new("141.213.0.0/16"),
          IPAddr.new("141.214.0.0/16"),
          IPAddr.new("192.12.80.0/24"),
          IPAddr.new("198.108.8.0/21"),
          IPAddr.new("198.111.224.0/22"),
          IPAddr.new("198.111.181.0/25"),
          IPAddr.new("207.75.144.0/20"),
          IPAddr.new("10.0.0.0/8"),
          IPAddr.new("127.0.0.0/8"),
          IPAddr.new("172.16.0.0/12"),
          IPAddr.new("192.168.0.0/16")
        ]

        FLINT_ADDRESSES = [
          IPAddr.new("141.216.0.0/16")
        ]

        KEEP_THESE_COOKIES = [
          "skynet",
          "STICKY",
          "rack.session",
          "_ga",
          "_gid",
          "_gat",
          "_clck",
          "_clsk",
          "ezproxy",
          "ezproxyl",
          "ezproxyn",
          "mod_auth_openidc_session",
        ]

        def manage_cookies
          domain = ENV.fetch("SPECTRUM_COOKIE_PURGE_DOMAIN", false)
          cookie_threshold = ENV.fetch("SPECTRUM_COOKIE_PURGE_THRESHOLD", 0).to_i
          max_cookies = ENV.fetch("SPECTRUM_COOKIE_PURGE_MAX_COOKIES", 30).to_i
          return unless domain
          return unless cookie_threshold > 0
          return unless env["HTTP_COOKIE"]
          return unless env["HTTP_COOKIE"].bytesize > cookie_threshold
          ActiveSupport::Notifications.instrument("cookie_purge.spectrum_json")
          request.cookies.keys.sort { |a, b| request.cookies[b].length <=> request.cookies[a].length }.slice(0, max_cookies).each do |name|
            next if KEEP_THESE_COOKIES.include?(name)
            response.delete_cookie(name, domain: domain)
          end
        end

        def get_origin
          env = request.env
          return env["HTTP_ORIGIN"] if env["HTTP_ORIGIN"]
          return "*" unless env["HTTP_REFERER"]
          uri = URI(env["HTTP_REFERER"])
          "#{uri.scheme}://#{uri.host}#{[80, 443].include?(uri.port) ? "" : ":" + uri.port.to_s}"
        end

        def cors
          manage_cookies
          headers["Access-Control-Allow-Origin"] = get_origin
          headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept, Authorization, Referer"
          headers["Access-Control-Allow-Credentials"] = "true"
          ""
        end

        def no_cache
          headers["Cache-Control"] = "no-cache, no-store"
          headers["Pragma"] = "no-cache"
          headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
        end

        def base_url
          {base_url: settings.relative_url_root}
        end

        def basic_response(spectrum_request:, spectrum_response:, messages: [])
          {
            request: spectrum_request.spectrum,
            response: spectrum_response.spectrum(filter_limit: -1),
            messages: messages.map(&:spectrum),
            total_available: spectrum_response.total_available,
            default_institution: default_institution,
            affiliation: default_affiliation
          }
        end

        def default_institution
          case IPAddr.new(get_ip_addr)
          when *AA_ADDRESSES
            "U-M Ann Arbor Libraries"
          when *FLINT_ADDRESSES
            "Flint Thompson Library"
          else
            "All libraries"
          end
        end

        def get_ip_addr
          if request.env["REMOTE_ADDR"] != "127.0.0.1"
            request.env["REMOTE_ADDR"]
          elsif request.env["HTTP_X_FORWARDED_FOR"]
            request.env["HTTP_X_FORWARDED_FOR"].split(/ /).last
          else
            "127.0.0.1"
          end
        end

        def default_affiliation
          case IPAddr.new(get_ip_addr)
          when *AA_ADDRESSES
            "aa"
          when *FLINT_ADDRESSES
            "flint"
          else
            "aa"
          end
        end
      end
    end
  end
end
