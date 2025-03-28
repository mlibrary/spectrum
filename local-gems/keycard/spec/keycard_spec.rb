# frozen_string_literal: true

RSpec.describe Keycard do
  it "has a version number" do
    expect(Keycard::VERSION).not_to be nil
  end
end
