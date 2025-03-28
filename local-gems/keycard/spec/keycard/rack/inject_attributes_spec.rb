# frozen_string_literal: true

require 'keycard/rack/inject_attributes'

RSpec.describe Keycard::Rack::InjectAttributes do
  let(:app) { ->(env) { env } }
  let(:middleware) { described_class.new(app, nil) }
  let(:response) { middleware.call(before: :before_value) }
  let(:attributes) { double(:attributes, all: { after: :after_value }) }

  describe "#call" do
    it 'merges data into the rack environment' do
      class_double('Keycard::RequestAttributes', new: attributes).as_stubbed_const

      expect(response.keys).to contain_exactly(:before, :after)
      expect(response.values).to contain_exactly(:before_value, :after_value)
    end
  end
end
