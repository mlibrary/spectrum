# frozen_string_literal: true

require_relative "../../spec_helper"

describe Spectrum::Holding::GetThisAction do

  context "#finalize" do
    context "with a basic example" do

      let(:id) { 'ID' }
      let(:bib) { nil }
      let(:holding) {{
        'item_status' => ''
      }}
      let(:item) { instance_double(Spectrum::Entities::AlmaItem, barcode: 'BARCODE', doc_id: 'ID') }
      let(:info) {{ 'can_request' => true, 'barcode' => 'BARCODE' }}
      let(:result) {{
        text: 'Get This',
        to: {
          barcode: 'BARCODE',
          action: 'get-this',
          record: 'ID',
          datastore: 'ID',
        }
      }}

      subject { described_class.new(item) }

      it 'returns an N/A cell.' do
        expect(subject.finalize).to eq(result)
      end
    end
  end
end
