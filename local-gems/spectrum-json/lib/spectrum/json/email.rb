# frozen_string_literal: true

require 'mail'
require 'htmlentities'

module Spectrum
  module Json
    class Email
      class << self
        attr_accessor :service, :client

        def configure!(config)
          self.service = config
          self.client = Mail
        end

        def text_header
          service.text_header + "\n"
        end

        def text_footer
          service.text_footer + "\n"
        end

        def html_header
          service.html_header
        end

        def html_footer
          service.html_footer
        end

        def text_format(messages)
          ret = text_header
          messages.each_with_index do |message, idx|
            ret << "Record #{idx + 1}:\n"
            ret << "#{title(message, "\n")}\n"
            ret << "#{url(message)}\n"
            ret << "*  Format: #{format(message, ', ')}\n"
            ret << "*  Author: #{author(message, ', ')}\n"
            ret << "*  Published: #{published(message)}\n"
            ret << "\n"
          end
          ret << text_footer
          ret
        end

        def format(message, glue)
          field(message, 'format', glue)
        end

        def author(message, glue)
          field(message, 'author', glue)
        end

        def published(message)
          field(message, 'published_brief')
        end

        def title(message, glue)
          field(message, 'title', glue)
        end

        def url(message)
          "#{field(message, 'base_url')}/#{field(message, 'id')}"
        end

        def encode(string)
          HTMLEntities.new.encode(string)
        end

        def html_format(messages)
          length = messages.length
          ret = String.new('<div>')
          ret << html_header
          ret << '<ul>'
          messages.each_with_index do |message, idx|
            locations = get_locations(message)
            location_count = locations.inject(0) do |memo, location|
              memo + location[:rows].length
            end

            format_content = format(message, ', ')
            author_content = author(message, ', ')
            published_content = published(message)

            ret << '<div>'
            ret << "<div>Record #{idx + 1}:</div>"
            ret << "<div>&nbsp;&nbsp;<strong>Record Title:</strong> <a href='#{encode(url(message))}'>#{encode(title(message, '<br>'))}</a></div>"
            ret << "<div>&nbsp;&nbsp;<strong>Format:</strong> #{encode(format_content)}</div>" if format_content
            ret << "<div>&nbsp;&nbsp;<strong>Main Author:</strong> #{encode(author_content)}</div>" if author_content
            ret << "<div>&nbsp;&nbsp;<strong>Published:</strong> #{encode(published_content)}</div>" if published_content
            if location_count > 6
              ret << '<p><em>[There are multiple items, locations or volumes associated with this record; please see the catalog record for full details.]</em></p>'
            else
              ret << format_locations_html(locations)
            end

            ret << '</article></li>'
          end
          ret << '</ul>'
          ret << html_footer
          ret << '</div>'
        end

        def location_type(location)
          return nil unless location[:caption]
          case location[:caption]
          when "Online Resources", "HathiTrust Digital Library"
            "Online Location"
          else
            "Physical Location"
          end
        end

        def location_cell(location, row, index)
          heading = location[:headings][index]
          cell = row[index]
          html_ready_value = case heading
          when "Description", "Call Number", "Source"
            encode(cell[:text])
          when "Link"
            "<a href='#{encode(cell[:href])}'>#{encode(cell[:text])}</a>"
          when "Status"
            if location[:caption].include?('Offsite') && cell[:text] == "On Shelf"
              "Use Get This to request this item"
            else
              encode(cell[:text])
            end
          else
            ""
          end
          return "" if html_ready_value.empty?
          "<div>&nbsp;&nbsp;&nbsp;&nbsp;<strong>#{heading}:</strong> #{html_ready_value}</div>"
        end

        def format_locations_html(locations)
          locations.reduce(String.new) do |memo, location|
            memo << "<div>&nbsp;&nbsp;<strong>#{location_type(location)}:</strong> #{location[:caption]}</div>"
            memo << "<div>&nbsp;&nbsp;<strong>Floor:</strong> #{location[:notes].join(", ")}</div>" if location[:notes]
            location[:rows].each do |row|
              (0...row.length).each do |index|
                memo << location_cell(location, row, index)
              end
            end
            memo
          end
        end

        def location_content(message, holdings)
          ret = String.new("<ol>")
          ret
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

        def get_locations(message)
          (
            raw_field_value(message, 'resource_access') +
            raw_field_value(message, 'holdings')
          ).compact.reject { |table| table[:rows].nil? || table[:rows].empty? }
        end

        def message(email_to, email_from, messages)
          text_content = text_format(messages)
          html_content = html_format(messages)
          subject_content = service.subject
          client.deliver do
            to   email_to
            from email_from
            subject subject_content
            delivery_method :sendmail

            text_part do
              content_type 'text/plain; charset=UTF-8'
              body text_content
            end

            html_part do
              content_type 'text/html; charset=UTF-8'
              body html_content
            end
          end
        end
      end
    end
  end
end
