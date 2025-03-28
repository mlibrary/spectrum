# frozen_string_literal: true

require 'keycard/yaml/institution_finder'

RSpec.describe Keycard::Yaml::InstitutionFinder do
  describe '#attributes_for' do
    let(:request) { double(:request, ip: remote_ip) }
    let(:attributes) { described_class.new(yaml: config_file).attributes_for(request) }
    let(:config_file) { File.expand_path('../../fixtures/files/yaml/config.yml', __dir__) }

    context 'with an ip with a single institution' do
      let(:remote_ip) { "10.0.0.1" }

      it "returns a hash with (only) a dlpsInstitutionId key" do
        expect(attributes.keys).to contain_exactly('dlpsInstitutionId')
      end

      it 'returns the correct institution' do
        expect(attributes['dlpsInstitutionId']).to contain_exactly(1)
      end
    end

    context "with an ip with multiple institutions" do
      let(:remote_ip) { "10.0.1.1" }
      it "returns the set of institutions" do
        expect(attributes['dlpsInstitutionId']).to contain_exactly(1, 2)
      end
    end

    context "with an IP address allowed and denied in the same institituion" do
      let(:remote_ip) { "10.0.2.1" }
      it "returns an empty hash" do
        expect(attributes).to eq({})
      end
    end

    context "with an IP address allowed in two insts and denied in one of them" do
      let(:remote_ip) { "10.0.3.1" }
      it "returns the institution it wasn't denied from" do
        expect(attributes['dlpsInstitutionId']).to contain_exactly(2)
      end
    end

    context "with an ip address not in any ranges" do
      let(:remote_ip) { "192.168.0.1" }
      it "returns an empty hash" do
        expect(attributes).to eq({})
      end
    end

    context "with an invalid IP address" do
      let(:remote_ip) { "10.0.324.456" }

      it "returns an empty hash" do
        expect(attributes).to eq({})
      end
    end

    context "with no ip" do
      let(:remote_ip) { nil }

      it "returns an empty hash" do
        expect(attributes).to eq({})
      end
    end
  end
end
