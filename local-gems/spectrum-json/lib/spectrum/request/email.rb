# frozen_string_literal: true

module Spectrum
  module Request
    class Email
      FLINT = 'Flint'
      FLINT_PROXY_PREFIX = 'http://libproxy.umflint.edu:2048/login?url='
      DEFAULT_PROXY_PREFIX = 'https://proxy.lib.umich.edu/login?url='
      INSTITUTION_KEY = 'dlpsInstitutionId'

      def proxy_prefix
        return FLINT_PROXY_PREFIX if @request.env[INSTITUTION_KEY]&.include?(FLINT)
        DEFAULT_PROXY_PREFIX
      end

      attr_reader :role, :request
      def initialize(request)
        @request = request
        @raw = CGI.unescape(request.raw_post)
        @data = JSON.parse(@raw)
        @username = request.env['HTTP_X_REMOTE_USER'] || ''
        @role = if request.env['dlpsInstitutionId'] &&
            request.env['dlpsInstitutionId'].length > 0
          'authenticated'
        else
          ''
        end
        @items = nil
      end

      def to
        @data['to']
      end

      def from
        return @username if @username.include?('@')
        "#{@username}@umich.edu"
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
          data['records'].each do |id|
            record = focus.fetch_record(Spectrum::Json.sources, id, role, self)
            yield record + [
              { uid: 'base_url', value: data['base_url'] },
              { uid: 'holdings', value: get_holdings(focus, id) }
            ]
          end
        end
      end

      def get_holdings(focus, id)
        source = Spectrum::Json.sources[focus.source]
        return [] unless source.holdings
        Spectrum::Response::Holdings.new(source, OpenStruct.new(id: id, focus: focus.id)).renderable
      end

      def each_focus
        @data.each_pair do |focus, ids|
          yield Spectrum::Json.foci[focus], ids
        end
      end

      def logged_in?
        !@username.empty?
      end
    end
  end
end
