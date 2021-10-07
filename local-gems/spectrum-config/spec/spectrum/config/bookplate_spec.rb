require_relative '../../spec_helper'
require_relative '../../config_stub'

require 'spectrum/config/bookplate'

describe Spectrum::Config::Bookplate do
  context "When initialized with args0/args1" do
    let(:args0) {{
      'id' => 'ID0',
      'uid' => 'UID0',
      'desc' => 'DESC0',
      'image' => 'IMAGE0',
    }}

    let(:args1) {{
      'id' => 'ID1',
      'uid' => 'UID1',
      'desc' => 'DESC1',
      'image' => 'IMAGE1',
    }}

    subject { described_class.new(args0) }

    let(:other) { described_class.new(args1) }

    context '#<=>' do
      it 'returns 0 when subject <=> subject' do
        expect(subject <=> subject).to eq(0)
      end
      it 'returns -1 when subject <=> other' do
        expect(subject <=> other).to eq(-1)
      end
      it 'returns 1 when other <=> subject' do
        expect(other <=> subject).to eq(1)
      end
    end

  end
end

