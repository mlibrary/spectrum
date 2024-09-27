require_relative "../../../spec_helper"

describe Spectrum::SearchEngines::Primo::Engine do
  context "#query" do
    subject { described_class.new(key: "KEY", host: "HOST", libkey: {}) }
    it "takes this form" do
      expect(subject.query).to eq("apikey=KEY&scope=default_scope&tab=default_tab&vid=Auto1")
    end
  end
end
