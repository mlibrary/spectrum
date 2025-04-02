# frozen_string_literal: true

require 'ipaddr'
require 'ostruct'

module Keycard
  module Yaml
    # Represent an institution defined by an IP range.
    class Institution
      attr_reader :first, :last, :name, :access

      class << self
        def parse_ip(dotted_ip)
          return unless dotted_ip
          ipaddr(dotted_ip).to_i
        end

        def parse_range(range)
          return [nil] unless range
          parsed_range = ipaddr(range).to_range
          [parsed_range.first.to_i, parsed_range.last.to_i]
        end

        private

        def ipaddr(string)
          IPAddr.new(string)
        rescue IPAddr::InvalidAddressError
          OpenStruct.new(to_i: nil, to_range: [OpenStruct.new(to_i: nil)])
        end
      end

      def initialize(inst)
        network = parse_range(inst['network'])
        @first = parse_ip(inst['first']) || network.first
        @last = parse_ip(inst['last']) || network.last
        @name = inst['name']
        @access = inst['access'] || 'allow'
        @allow = @access == 'allow'
      end

      def allow?
        @allow
      end

      def deny?
        !@allow
      end

      def match?(numeric_ip)
        return self if first <= numeric_ip && numeric_ip <= last
        nil
      end

      private

      def parse_ip(dotted_ip)
        self.class.parse_ip(dotted_ip)
      end

      def parse_range(range)
        self.class.parse_range(range)
      end
    end
  end
end
