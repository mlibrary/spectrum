module Spectrum
  module Request
    class Action
      attr_reader :request, :role, :username

      def initialize(request:, username:)
        @request = request
        if request.post?
          request.env["rack.input"].rewind
          @raw = CGI.unescape(request.env["rack.input"].read)
          @data = JSON.parse(@raw)
        end
        @username = username || ""
        @role = if request.env["dlpsInstitutionId"] &&
            request.env["dlpsInstitutionId"].length > 0
          "authenticated"
        else
          ""
        end
        @items = nil
      end

      def items
        return @items if @items
        ret = []
        each_item do |item|
          ret << item
        end
        @items = ret
      end

      def each_item
        @data.each_pair do |focus_uid, data|
          focus = Spectrum::Json.foci[focus_uid]
          next unless focus
          data["records"].each do |id|
            record = focus.fetch_record(Spectrum::Json.sources, id, role, self)
            yield record + [{uid: "base_url", value: data["base_url"]}]
          end
        end
      end

      def logged_in?
        !@username.empty?
      end

      def proxy_prefix
        ""
      end
    end
  end
end
