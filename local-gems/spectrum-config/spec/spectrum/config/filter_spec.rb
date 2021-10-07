require_relative '../../spec_helper'

require 'spectrum/config/filter'

describe Spectrum::Config::Filter do

  context "Configured with marc555" do
    let(:cfg) {{'id' => 'marc555', 'method' => 'marc555'}}
    subject { described_class.new(cfg) }
    let(:link_data) {
      [
        [
         {uid: 'text', name: 'text', value: 'TEXT'},
         {uid: 'href', name: 'href', value: 'http://example.com'}
        ]
      ]
    }
    let(:link_results) {[{'text' => 'TEXT', 'href' => 'http://example.com'}]}
    let(:text_data) {[[{uid: 'text', name: 'text', value: 'TEXT'}]]}
    let(:text_results) {[{'text' => 'TEXT'}]}
    let(:replace_data) {[
      [{uid: 'text', name: 'text', value: 'TEXT via World Wide Web at URL:'}],
      [{uid: 'text', name: 'text', value: 'TEXT via the World Wide Web at URL:'}],
      [{uid: 'text', name: 'text', value: 'TEXT via the World Wide web at URL:'}],
      [{uid: 'text', name: 'text', value: 'TEXT via the World Wide Web.'}],
      [{uid: 'text', name: 'text', value: 'TEXT via the Internet.'}],
      [{uid: 'text', name: 'text', value: 'TEXT available at http://example.com'}],
      [{uid: 'text', name: 'text', value: 'TEXT: http://example.com'}],
    ]}
    let(:replace_results) {[
      {'text' => 'TEXT online'},
      {'text' => 'TEXT online'},
      {'text' => 'TEXT online'},
      {'text' => 'TEXT online'},
      {'text' => 'TEXT online'},
      {'text' => 'TEXT available online'},
      {'text' => 'TEXT available online'},
    ]}

    let(:multiple_value_data) {[[
      {uid: 'text', name: 'text', value: '$a'},
      {uid: 'text', name: 'text', value: '$b'},
      {uid: 'href', name: 'href', value: 'http://example.com/1'},
      {uid: 'href', name: 'href', value: 'http://example.com/2'},
    ]]}
    let(:multiple_value_results) {[
      {'text' => '$a $b', 'href' => 'http://example.com/1'},
    ]}

    context "#apply" do
      it "returns nil when given nil" do
        expect(subject.apply(nil, nil)).to be(nil)
      end

      it "returns [] when given []" do
        expect(subject.apply([], nil)).to eq([])
      end

      it "returns link data when given link info" do
        expect(subject.apply(link_data, nil)).to eq(link_results)
      end

      it "removes some urls from the text" do
        expect(subject.apply(replace_data, nil)).to eq(replace_results)
      end
    end
  end

  context "Configured with boolean" do
    let(:cfg) {{'id' => 'boolean', 'method' => 'boolean'}}
    subject { described_class.new(cfg) }
    context "#apply" do
      it "returns nil when given nil" do
        expect(subject.apply(nil, nil)).to be(nil)
      end

      it "returns [] when given []" do
        expect(subject.apply([], nil)).to eq([])
      end

      it "returns 'Yes' when given 'true'" do
        expect(subject.apply('true', nil)).to eq('Yes')
      end

      it "returns 'Yes' when given true" do
        expect(subject.apply(true, nil)).to eq('Yes')
      end

      it "returns 'Yes' when given 'yes'" do
        expect(subject.apply('yes', nil)).to eq('Yes')
      end

      it "returns nil when given 'false'" do
        expect(subject.apply('false', nil)).to be(nil)
      end

      it "returns nil when given false" do
        expect(subject.apply(false, nil)).to eq(nil)
      end

      it "returns nil when given 'no'" do
        expect(subject.apply('no', nil)).to eq(nil)
      end
    end
  end

end
