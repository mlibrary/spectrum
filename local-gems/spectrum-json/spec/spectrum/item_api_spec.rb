# frozen_string_literal: true

require_relative '../spec_helper'

holdings = Spectrum::Entities::Holdings.new(JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_getHoldings.json')))

[
  Spectrum::Decorators::MirlynItemDecorator.new(holdings[1].items[0], holdings.hathi_holdings),
  Spectrum::AvailableOnlineHolding.new(nil),
].each do |instance|
  describe instance.class do
    [
      'doc_id', 'callnumber', 'status', 'location',
      'notes', 'issue', 'can_book?', 'can_reserve?',
      'can_request?', 'circulating?', 'on_shelf?',
      'on_site?', 'off_site?', 'reopened?',
    ].each do |method|
      #subject { described_class.new(*args) }
      context "##{method}" do
        it "respond_to? #{method}" do
          expect(instance.respond_to?(method)).to be(true)
        end
      end
    end
  end
end
