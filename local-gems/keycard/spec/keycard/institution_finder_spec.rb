# frozen_string_literal: true

require "keycard/institution_finder"
require "sequel_helper"
require "ipaddr"

RSpec.describe Keycard::InstitutionFinder, DB: true do
  describe "#attributes_for" do
    let(:request) { double(:request, remote_ip: remote_ip) }

    def add_inst_network(inst:, network:, access:)
      @unique_id ||= 0
      @unique_id += 1
      range = IPAddr.new(network).to_range
      Keycard::DB[:aa_network].insert([@unique_id, nil, network, range.first.to_i, range.last.to_i,
                                       access.to_s, nil, inst, Time.now.utc, 'test', 'f'])
    end

    before(:each) do
      add_inst_network(inst: 1, network: '10.0.0.0/16', access: :allow)
      add_inst_network(inst: 1, network: '10.0.2.0/24', access: :deny)

      # range in two institutions
      add_inst_network(inst: 2, network: '10.0.1.0/24', access: :allow)

      # denied from one, allowed to another
      add_inst_network(inst: 1, network: '10.0.3.0/24', access: :deny)
      add_inst_network(inst: 2, network: '10.0.3.0/24', access: :allow)
    end

    let(:attributes) { described_class.new.attributes_for(request) }

    context "with an ip with a single institution" do
      let(:remote_ip) { "10.0.0.1" }

      it "returns a hash with (only) a dlpsInstitutionId key" do
        expect(attributes.keys).to contain_exactly('dlpsInstitutionId')
      end

      it "returns the correct institution" do
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
