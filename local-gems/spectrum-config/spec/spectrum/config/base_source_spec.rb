require_relative '../../spec_helper'
require 'spectrum/config/base_source'

describe Spectrum::Config::BaseSource do
  context '#<=>' do
    let(:first) { described_class.new({ 'id' => 0}) }
    let(:second) { described_class.new({'id' => 1}) }

    it 'sorts first before second' do
      expect(first <=> second).to eq(-1)
    end

    it 'sorts first before second' do
      expect(second <=> first).to eq(1)
    end

    it 'sorts first equal to first' do
      expect(first <=> first).to eq(0)
    end
  end

  context '#is_solr?' do
    subject { described_class.new({}) }
    it 'returns false' do
      expect(subject.is_solr?).to be(false)
    end
  end

  context '#[]' do
    let(:id) { 'ID' }
    subject { described_class.new({ 'id' => id })}
    it 'returns id when passed "id"' do
      expect(subject['id']).to eq(id)
    end
  end

  context '#merge!' do
    let(:first) { 'ID' }
    let(:second) { 'NEW ID' }
    subject do
      described_class.new({'id' => first}).tap do |instance|
        instance.merge!({'id' => second})
      end
    end

    it 'returns NEW ID' do
      expect(subject.id).to eq(second)
    end
  end

end

