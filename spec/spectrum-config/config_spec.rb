require_relative '../rails_helper.rb'

require 'spectrum/config'

describe Spectrum::Config do
  context "require 'spetrum/config'" do
    it "loads successfully" do
      expect(Spectrum::Config).to be(Spectrum::Config)
    end
  end
end
