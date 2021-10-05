# frozen_string_literal: true

module Spectrum
  module Response
    class Holdings
      def initialize(source, request, 
                     holdings: Spectrum::Entities::CombinedHoldings.for(source, request),
                     holding_factory: lambda{|holding| Spectrum::Presenters::HoldingPresenter.for(holding)}
                    )
        @holdings = holdings

        @holding_factory = holding_factory

        @data = process_response
      end

      def renderable
        @data
      end

      private

      def process_response
        data = []
        sorter = Hash.new { |hash, key| hash[key] = key }.tap do |hash|
          hash[nil] = 'AAAC'
          hash['Online Resources'] = 'AAAA'
          hash['HathiTrust Digital Library'] = 'AAAB'
          hash['- Offsite Shelving -'] = 'zzzz'
        end
        @holdings.each do |holding|
          holding_presenter = @holding_factory.call(holding)
          if holding_presenter.class.to_s.match?(/LinkedHolding/) || holding.items.count > 0
            data << holding_presenter.to_h          
          end
        end
        data = data.reject do |item|
          !item.has_key?(:rows) || item[:rows].empty?
        end.sort_by do |item|
          sorter[item[:caption]]
        end
        expanded = data.length == 1
        data.each do |item|
          item[:preExpanded] = expanded
        end
      end
    end
  end
end
