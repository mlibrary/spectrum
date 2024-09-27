require_relative "../../../spec_helper"
require_relative '../../../config_stub'

describe Spectrum::Config::CSLAggregator do
  context '#spectrum' do
    context 'empty results' do
      let(:results) {{
        :name => "CSL",
        :uid => "csl",
        :value => {},
        :value_has_html => true,
      }}
      it 'returns an empty hash' do
        expect(subject.spectrum).to eq(results)
      end
    end

    context 'scalar results' do
      let(:data) {{'ID' => 'VALUE'}}
      subject { described_class.new.merge!(data) }
      let(:results) {{
        :name => "CSL",
        :uid => "csl",
        :value => data,
        :value_has_html => true,
      }}

      it 'returns a hash to a string' do
        expect(subject.spectrum).to eq(results)
      end
    end

    context 'list results' do
      let(:data1) {{'ID' => ['VALUE1']}}
      let(:data2) {{'ID' => ['VALUE2']}}
      subject { described_class.new.merge!(data1).merge!(data2) }
      let(:results) {{
        :name => "CSL",
        :uid => "csl",
        :value => {'ID' => ['VALUE1', 'VALUE2']},
        :value_has_html => true,
      }}

      it 'returns 2 values' do
        expect(subject.spectrum).to eq(results)
      end
    end
  end
end

