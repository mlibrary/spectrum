require_relative '../../../rails_helper'
require 'spectrum/config/base_source'
require 'spectrum/config/solr_source'

describe Spectrum::Config::SolrSource do
  context '#is_solr?' do
    subject { described_class.new({}) }

    it 'returns true' do
      expect(subject.is_solr?).to be(true)
    end
  end
end
