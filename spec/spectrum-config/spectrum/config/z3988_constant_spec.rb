require_relative "../../../spec_helper"

describe Spectrum::Config::Z3988Constant do
  context "#value" do
    let(:example_1_config) {{
      "id" => "EXAMPLE_ID",
      "constant" => "EXAMPLE_CONSTANT",
      "namespace" => "EXAMPLE_NAMESPACE:",
    }}
    let(:example_1_results) { "EXAMPLE_ID=EXAMPLE_NAMESPACE%3AEXAMPLE_CONSTANT" }
    subject { described_class.new(example_1_config) }

    it "Returns url-encoded KEV without arguments" do
      expect(subject.value).to eq(example_1_results)
    end

    it "Returns url-encoded KEV with nil" do
      expect(subject.value(nil)).to eq(example_1_results)
    end

    it "Returns url-encoded KEV with string" do
      expect(subject.value('example')).to eq(example_1_results)
    end
  end
end

