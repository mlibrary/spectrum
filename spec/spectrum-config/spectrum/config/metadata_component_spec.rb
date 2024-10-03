require_relative "../../../spec_helper"

describe Spectrum::Config::MetadataComponent do
  context "When initialized with nil/nil" do
    subject { described_class.new(nil, nil) }
    context "#resolve" do
      it "returns nil when given nil" do
        expect(subject.resolve(nil)).to be(nil)
      end
      it "returns nil when given true" do
        expect(subject.resolve(true)).to be(nil)
      end
      it "returns nil when given false" do
        expect(subject.resolve(false)).to be(nil)
      end
    end
  end

  context "When initialized with nil/{}" do
    subject { described_class.new(nil, {}) }
    context "#resolve" do
      it "returns nil when given nil" do
        expect(subject.resolve(nil)).to be(nil)
      end
      it "returns nil when given true" do
        expect(subject.resolve(true)).to be(nil)
      end
      it "returns nil when given false" do
        expect(subject.resolve(false)).to be(nil)
      end
    end
  end

  context "When initialized with nil/{'type' => 'plain'}" do
    subject { described_class.new(nil, {'type' => 'plain'}) }
    context "#class" do
      it "is PlainMetadataComponent" do
        expect(subject.class).to be(Spectrum::Config::PlainMetadataComponent)
      end
    end
  end
end
