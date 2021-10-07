# frozen_string_literal: true

module Spectrum
  module Json
    class Twilio
      class << self
        attr_accessor :service, :client
        def configure!(config)
          self.service = config.service
          self.client  = ::Twilio::REST::Client.new(config.account, config.token)
          self
        end

        def message(to, messages)
          return [] unless to =~ /^[0-9]{10,10}$/
          messages.each_with_index.map do |message, index|
            client.messages.create(to: "1#{to}", from: service, body: format(message, index))
          end
        end

        def format(message, index = nil)
          holdings = get_holdings(message)
          ret = String.new('')
          ret << "Record #{index + 1}: \n" if index
          ret << title(message)
          case holdings.length
          when 0
            ret << link(message)
          when 1, 2
            last_location = ''
            holdings.each do |holding|
              ret << " Location: #{holding['location']}\n" unless last_location == holding['location']
              ret << " Description/Status: #{holding['description']} (#{holding['status']})\n"
              ret << " Call Number: #{holding['callnumber']}\n"
              last_location = holding['location']
            end
            ret << " Catalog Record: #{url(message)}"
          else
            ret << " There are multiple items available; see the catalog record for a list: \n"
            ret << url(message)
          end
          ret
        end

        def get_holdings(message)
          raw_field_value(message, 'holdings')
        end

        def field(message, uid, glue = nil)
          if glue
            field_value(message, uid).join(glue)
          else
            field_value(message, uid).first
          end
        end

        def field_value(message, uid)
          raw_field_value(message, uid).map(&:to_s)
        end

        def raw_field_value(message, uid)
          [(message.find { |field| field[:uid] == uid } || {})[:value]].flatten.compact
        end

        def title(message)
          " Title: #{field(message, 'title', "\n")}\n"
        end

        def link(message)
          " Link: #{url(message)}"
        end

        def url(message)
          "#{field(message, 'base_url')}/#{field(message, 'id')}"
        end
      end
    end
  end
end
