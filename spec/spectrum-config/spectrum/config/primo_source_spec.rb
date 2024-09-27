require_relative "../../../spec_helper"

describe Spectrum::Config::PrimoSource do
  describe "#extract_query" do
    subject { described_class.new({}) }
    let(:marshal1) { File.expand_path(
      '../../../../fixtures/spectrum/config/primo_source_01.marshal',
      __FILE__
    ) }
    let(:args1) { Marshal.load(IO.binread(marshal1)) }
    let(:response1) { subject.extract_query(*args1) }
    let(:ideal1) { "any,exact,apple,NOT;any,exact,orange" }
    it "generates parameters" do
      expect(response1).to eq(ideal1)
    end
  end
end

