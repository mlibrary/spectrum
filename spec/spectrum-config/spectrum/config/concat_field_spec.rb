require_relative "../../../spec_helper"
require_relative '../../../config_stub'
require_relative '../../../spec_data'

describe Spectrum::Config::ConcatField do

  context '#initialize_from_instance' do
    let(:args01) { SpecData.load_json('args-001.json', __FILE__) }
    let(:args02) { SpecData.load_json('args-002.json', __FILE__) }
    let(:config) { ConfigStub.new }
    let(:instance2) { described_class.new(args02, config) }
    subject do
      described_class.new(args01, config).tap do |instance1|
        instance1.initialize_from_instance(instance2)
      end
    end

    it 'returns "" for .join' do
      expect(subject.join).to eq("")
    end
  end

  context "#value" do

    context "When initialized without a join" do
      let(:args) { SpecData.load_json('args-002.json', __FILE__) }
      let(:config) { ConfigStub.new }
      let(:data) { { "title" => "TITLE", "subtitle" => "SUBTITLE" } }
      let(:result) { "TITLESUBTITLE" }
      subject { described_class.new(args, config) }

      it 'returns nil when called on nil' do
        expect(subject.value(nil, nil)).to eq(nil)
      end

      it "returns 'concatenated' values" do
        expect(subject.value(data, nil)).to eq(result)
      end
    end

    context "When initialized with a join" do
      let(:args) { SpecData.load_json('args-001.json', __FILE__) }
      let(:config) { ConfigStub.new }
      let(:data) { { "title" => "TITLE", "subtitle" => "SUBTITLE" } }
      let(:result) { "TITLE : SUBTITLE" }
      subject { described_class.new(args, config) }

      it 'returns nil when called on nil' do
        expect(subject.value(nil, nil)).to eq(nil)
      end

      it "returns 'concatenated' values" do
        expect(subject.value(data, nil)).to eq(result)
      end
    end

  end
end

