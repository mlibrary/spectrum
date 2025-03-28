# frozen_string_literal: true

RSpec.describe Keycard::Yaml::Institution do
  describe '::parse_ip' do
    let(:numeric_ip) { described_class.parse_ip(ip) }

    context 'with a valid ip' do
      let(:ip) { '127.0.0.1' }
      it 'returns an integer' do
        expect(numeric_ip).to be(2_130_706_433)
      end
    end

    context 'with an invalid ip' do
      let(:ip) { nil }
      it 'returns nil' do
        expect(numeric_ip).to be(nil)
      end
    end
  end

  describe '::parse_range' do
    let(:range) { described_class.parse_range(network) }
    let(:first_ip) { range.first }
    let(:last_ip) { range.last }

    context 'with a valid range' do
      let(:network) { '127.0.0.1/16' }

      it 'returns a "range"' do
        expect(first_ip).to be(2_130_706_432)
        expect(last_ip).to be(2_130_771_967)
      end
    end

    context 'with an invalid range' do
      let(:network) { nil }

      it 'returns nil for first and last' do
        expect(first_ip).to be(nil)
        expect(last_ip).to be(nil)
      end
    end
  end

  describe '#allow?' do
    context 'with "access" => "allow"' do
      let(:allowed) { described_class.new('access' => 'allow').allow? }

      it 'returns truthy' do
        expect(allowed).to be(true)
      end
    end

    context 'with "access" => "deny"' do
      let(:allowed) { described_class.new('access' => 'deny').allow? }

      it 'returns falsey' do
        expect(allowed).to be(false)
      end
    end
  end

  describe '#deny?' do
    context 'with "access" => "allow"' do
      let(:allowed) { described_class.new('access' => 'allow').deny? }

      it 'returns falsey' do
        expect(allowed).to be(false)
      end
    end

    context 'with "access" => "deny"' do
      let(:allowed) { described_class.new('access' => 'deny').deny? }

      it 'returns truthy' do
        expect(allowed).to be(true)
      end
    end
  end

  describe '#match?' do
    let(:inside_ip) { described_class.parse_ip('127.0.0.1') }
    let(:outside_ip) { described_class.parse_ip('127.0.1.1') }

    context 'with an ip range' do
      let(:institution) { described_class.new('network' => '127.0.0.0/24') }

      it 'returns itself when ip is within the range' do
        expect(institution.match?(inside_ip)).to be(institution)
      end

      it 'returns nil when ip is outside the range' do
        expect(institution.match?(outside_ip)).to be(nil)
      end
    end

    context 'with first and last ips' do
      let(:institution) { described_class.new('first' => '127.0.0.0', 'last' => '127.0.0.255') }

      it 'returns itself when ip is within the range' do
        expect(institution.match?(inside_ip)).to be(institution)
      end

      it 'returns nil when ip is outside the range' do
        expect(institution.match?(outside_ip)).to be(nil)
      end
    end
  end
end
