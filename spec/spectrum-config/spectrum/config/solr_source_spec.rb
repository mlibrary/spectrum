require_relative "../../../spec_helper"

describe Spectrum::Config::SolrSource do
  context '#is_solr?' do
    subject { described_class.new({}) }

    it 'returns true' do
      expect(subject.is_solr?).to be(true)
    end
  end
end
