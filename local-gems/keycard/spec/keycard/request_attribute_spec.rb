# frozen_string_literal: true

require "keycard/request_attributes"

module Keycard
  RSpec.describe RequestAttributes do
    let(:request) { double(:request) }
    let(:attributes) { {} }
    let(:finder) { double(:finder, attributes_for: attributes) }
    let(:request_attributes) { described_class.new(request, finder: finder) }

    it "takes a request" do
      expect(request_attributes).not_to be(nil)
    end

    context "with a finder that returns an attribute" do
      let(:attributes) { { foo: 'bar' } }

      it "can get the value of that attribute" do
        expect(request_attributes[:foo]).to eq('bar')
      end
    end

    describe "#all" do
      let(:attributes) { { foo: 'bar', baz: 'quux' } }

      it "returns all the attributes" do
        expect(request_attributes.all).to eq(attributes)
      end
    end
  end
end
