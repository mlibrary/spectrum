require_relative '../../../rails_helper'
require_relative '../../../config_stub'

require 'marc'

require 'spectrum/config/field'
require 'spectrum/config/basic_field'
require 'spectrum/config/marcxml_field'
require 'spectrum/config/formatted_catalog_published_field'

describe Spectrum::Config::FormattedCatalogPublishedField do
  context "When initialized this way" do
    let(:args) { SpecData.load_json('args-001.json', __FILE__) }
    let(:config) { ConfigStub.new }

    subject { described_class.new(args, config) }

    context "#value given multiple publishers" do
      let(:data) { SpecData.load_bin('example-001.bin', __FILE__) }

      let(:results) { SpecData.load_json('results-001.json', __FILE__) }

      it "returns multiple values" do
        expect(subject.value(data)).to eq(results)
      end
    end
  end
end

