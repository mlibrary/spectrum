require_relative "../../../spec_helper"

describe Spectrum::Config::PrimoSource do
  describe "#extract_query" do
    subject { described_class.new({}) }
    let(:marshals) { [ File.expand_path(
        '../../../../fixtures/spectrum/config/primo_source_01.marshal',
        __FILE__
      ),
      File.expand_path(
        '../../../../fixtures/spectrum/config/primo_source_02.marshal',
        __FILE__
      ),
      File.expand_path(
        '../../../../fixtures/spectrum/config/primo_source_03.marshal',
        __FILE__
      )
    ]}
    let(:argses) { marshals.map {|marshal| Marshal.load(IO.binread(marshal)) } }
    let(:responses) { argses.map { |args| subject.extract_query(*args) } }
    let(:ideals) { [
      "any,exact,apple,NOT;any,exact,orange",
      "any,exact,(\"mitt romney\" OR \"Romney, Mitt\"),NOT;any,exact,\"Standalone Media Collections\"",
      "title,contains,finn,OR;creator,contains,twain"
    ] }

    it "generates parameters for negation" do
      expect(responses[0]).to eq(ideals[0])
    end

    it "generates disjunction-friendly parameters" do
      expect(responses[1]).to eq(ideals[1])
    end

    it "generates more disjunction-friendly parameters" do
      expect(responses[2]).to eq(ideals[2])
    end
  end
end

