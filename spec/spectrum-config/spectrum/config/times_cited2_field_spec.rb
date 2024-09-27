require_relative "../../../spec_helper"
require_relative '../../../config_stub'
require_relative '../../../summon_document_stub'

describe Spectrum::Config::TimesCited2Field do
  context "When initialized this way" do
    let(:args) { SpecData.load_json('args-001.json', __FILE__) }
    let(:config) { ConfigStub.new }

    subject { described_class.new(args, config) }

    context "#value given multiple publishers" do
      let(:data) { SpecData.load_json('example-001.json', __FILE__) }
      let(:doc) { SummonDocumentStub.new(data) }

      let(:results) { SpecData.load_json('results-001.json', __FILE__) }

      it "returns multiple values" do
        expect(subject.value(doc)).to eq(results)
      end
    end
  end
end

