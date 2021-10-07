# frozen_string_literal: true

module Spectrum
  module Response
    class Record
      def initialize(args = {}, request)
        @data     = args[:data]
        @focus    = args[:focus]
        @source   = args[:source]
        @base_url = args[:base_url]
        @position = args[:position]
        @request  = request

        if @data.respond_to? :[]
          initialize_from_hash
        else
          initialize_from_object
        end
      end

      def initialize_from_hash
        @url             = @focus.get_url(@data, @base_url)
        @type            = @data['type'] || @source.id
        @complete        = @data['complete'] || true
        @fields          = @focus.apply_fields(@data, @base_url, @request)
        @names           = @focus.names(@fields)
        @uid             = @fields.find { |f| f[:uid] == 'id' }[:value]
        @alt_ids         = @fields.find { |f| f[:uid] == 'alt_ids' }&.dig(:value) || [@uid]
        @names_have_html = @data['names_have_html'] || true
        @metadata        = @focus.metadata_component(@data, @base_url, @request)
        @formats         = @focus.icons(@data, @base_url, @request)
        @header          = @focus.header_component(@data, @base_url, @request)
      end

      def initialize_from_object
        @url             = @focus.get_url(@data, @base_url)
        @type            = @data.content_types || @source.id
        @fields          = @focus.apply_fields(@data, @base_url, @request)
        @names           = @focus.names(@fields)
        @uid             = @fields.find { |f| f[:uid] == 'id' }[:value]
        @alt_ids         = @fields.find { |f| f[:uid] == 'alt_ids' }&.dig(:value) || [@uid]
        @complete        = true
        @names_have_html = true
        @metadata        = @focus.metadata_component(@data, @base_url, @request)
        @formats         = @focus.icons(@data, @base_url, @request)
        @header          = @focus.header_component(@data, @base_url, @request)
      end

      def spectrum
        {
          type: @type,
          source: @url,
          complete: @complete,
          names: @names,
          formats: @formats,
          uid: @uid,
          alt_ids:  @alt_ids,
          datastore: @focus.id,
          names_have_html: @names_have_html,
          has_holdings: @focus.has_holdings?,
          fields: @fields,
          position: @position,
          metadata: @metadata,
          header: @header 
        }
      end
    end
  end
end
