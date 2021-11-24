require_relative '../../rails_helper'
require_relative '../../config_stub'

require 'spectrum/config/field'
require 'spectrum/config/basic_field'

describe Spectrum::Config::Field do
  let(:field_def1) {{
    'id' => 'ID1',
    'weight' => 20,
    'metadata' => {'name' => 'Field 1'}
  }}

  let(:field_def2) {{
    'id' => 'ID2',
    'weight' => 10,
    'metadata' => {'name' => 'Field 2'},
    'searchable' => false,
  }}

  let(:other) { described_class.new(field_def2, config) }

  let(:config) { ConfigStub.new }

  subject { described_class.new(field_def1, config) }

  context '#initialize' do
    let(:field_def3) {{
      'id' => 'ID3',
    }}

    let(:exception1) do
      begin
        described_class.new(field_def3, config)
      rescue Exception => e
        e.message
      end
    end

    let(:exception2)  do
      begin
        described_class.new('field_id', {})
      rescue Exception => e
        e.message
      end
    end

    let(:copied_instance) { described_class.new('ID1', {'ID1' => subject}) }

    it 'throws an exception with missing metadata' do
      expect(exception1).to eq('{"id"=>"ID3"}')
    end

    it 'throws an exception with a field id and missing definition' do
      expect(exception2).to eq("Unknown field type 'field_id'");
    end

    it 'copies instances from a known config' do
      expect(copied_instance.id).to eq('ID1')
    end
  end

  context '#type' do
    it "returns 'basic'" do
      expect(subject.type).to eq('basic')
    end
  end

  context '#empty?' do
    it 'returns false' do
      expect(subject.empty?).to be(false)
    end
  end

  context '#pseudo_facet?' do
    it 'returns false' do
      expect(subject.pseudo_facet?).to be(false)
    end
  end

  context '#searchable?' do
    it 'returns true' do
      expect(subject.searchable?).to be(true)
    end
  end

  context "#spectrum" do
    let(:result) {{
      default_value: "",
      fixed: false,
      metadata: {:name=>"Field 1", :short_desc=>nil},
      required: false,
      uid: "ID1",
    }}

    it 'returns a spectrum hash' do
      expect(subject.spectrum).to eq(result)
    end

    it 'returns nil when not searchable' do
      expect(other.spectrum).to be(nil)
    end
  end

  context '#apply' do
    let(:value) { 'VALUE' }

    let(:data1) {{
      subject.field => value,
    }}

    let(:data2) {
       Struct.new(:ID1).new(value)
    }

    let(:data3) {
       Struct.new(:src).new(data1)
    }

    let(:result) {{
      name: subject.name,
      uid: subject.uid,
      value: value,
      value_has_html: true,
    }}

    it 'returns nil when given nil' do
      expect(subject.apply(nil, nil)).to be(nil)
    end

    it 'returns value when given {field=>value}' do
      expect(subject.apply(data1, nil)).to eq(result)
    end

    it 'returns value when given a struct' do
      expect(subject.apply(data2, nil)).to eq(result)
    end

    it 'returns value when given a struct with a src key' do
      expect(subject.apply(data2, nil)).to eq(result)
    end
  end

  context '#list?' do
    it 'returns true' do
      expect(subject.list?).to be(true)
    end
  end

  context '#full?' do
    it 'returns true' do
      expect(subject.full?).to be(true)
    end
  end

  context '#<=>' do
    it 'subject <=> other returns 1' do
      expect(subject <=> other).to be(1)
    end

    it 'subject <=> subject returns 0' do
      expect(subject <=> subject).to be(0)
    end

    it 'other <=> subject returns -1' do
      expect(other <=> subject).to be(-1)
    end
  end

  context '#[]' do
    it 'calls send' do
      expect(subject['name']).to eq('Field 1')
    end
  end
end

