module Spectrum
  module SearchEngines
    module Primo
      class Info

        attr_accessor :first, :last, :total

        def self.for_json(json)
          json ||= {'total' => 0, 'first' => 0, 'last' => 0}
          self.new(total: json['total'], first: json['first'], last: json['last'])
        end

        def initialize(total: 0, first: 0, last: 0)
          @total = total
          @first = first
          @last = last
        end
      end
    end
  end
end
