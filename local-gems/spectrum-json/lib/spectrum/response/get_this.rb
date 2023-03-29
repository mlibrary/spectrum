# frozen_string_literal: true

# refactor to use item decorator
module Spectrum
  module Response
    class GetThis
      def initialize(source:, request:,
        get_this_policy_factory: lambda { |patron, bib, item| Spectrum::Entities::GetThisOptions.for(patron, bib, item) },
        user: Spectrum::Entities::AlmaUser.for(username: request.username),
        bib_record: Spectrum::BibRecord.fetch(id: request.id, url: source.url))
        @source = source
        @request = request

        @get_this_policy_factory = get_this_policy_factory

        @bib_record = bib_record

        @user = user

        @data = fetch_get_this
      end

      def renderable
        @data
      end

      private

      def needs_authentication
        {status: "Not logged in", options: []}
      end

      def patron_not_found
        {status: "Patron not found", options: []}
      end

      def patron_expired
        {status: "Your library account has expired. Please contact circservices@umich.edu for assistance.", options: []}
      end

      def fetch_get_this
        return {} unless @source.holdings
        return needs_authentication unless @request.logged_in?
        return patron_not_found if @user.empty?
        return patron_expired if @user.expired?

        {
          status: "Success",
          options: @get_this_policy_factory.call(@user, @bib_record, item)
        }
      end

      def item
        case @request.barcode
        when "available-online"
          Spectrum::AvailableOnlineHolding.new(@request.id)
        when "unavailable"
          Spectrum::EmptyItemHolding.new(@bib_record)
        else
          alma_holdings = Spectrum::Entities::AlmaHoldings.for(bib_record: @bib_record)
          item = alma_holdings.find_item(@request.barcode)
          Spectrum::Decorators::PhysicalItemDecorator.new(item)
        end
      end
    end
  end
end
