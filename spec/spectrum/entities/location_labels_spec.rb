require_relative '../../spec_helper'
describe Spectrum::Entities::LocationLabels do
  context '::options' do
    before(:each) do
      Spectrum::Entities::LocationLabels.configure('spec/fixtures/location_labels.yml')
    end
    it "returns appropriate display text for a library code" do
      expect(described_class.get_this('HATCH')).to eq('Hatcher Graduate Library')
    end
  end
end
