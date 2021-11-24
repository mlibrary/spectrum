require_relative '../../rails_helper'
require_relative '../../config_stub'

require 'spectrum/config/field'
require 'spectrum/config/basic_field'
require 'spectrum/config/constant_field'

describe Spectrum::Config::ConstantField do
  context "When initialized this way" do
    let(:args) { SpecData.load_json('args-001.json', __FILE__) }
    let(:config) { ConfigStub.new }

    subject { described_class.new(args, config) }

    context "#value" do
      it "returns 'constant' values" do
        expect(subject.value(nil, nil)).to eq('const')
      end
    end
  end
end

