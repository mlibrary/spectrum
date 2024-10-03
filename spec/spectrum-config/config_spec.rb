require_relative "../spec_helper.rb"

describe Spectrum::Config do
  context "require 'spetrum/config'" do
    it "loads successfully" do
      expect(Spectrum::Config).to be(Spectrum::Config)
    end
  end
end
