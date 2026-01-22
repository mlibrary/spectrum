require_relative "../../spec_helper"

describe Spectrum::Request::DataStore do
  describe "retrieve_specialists?" do
    it "returns true by default when settings is nil" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance"
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_specialists?).to be true
    end

    it "returns true when settings is empty" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_specialists?).to be true
    end

    it "returns true when specialists setting is true" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {"specialists" => true}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_specialists?).to be true
    end

    it "returns false when specialists setting is false" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {"specialists" => false}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_specialists?).to be false
    end
  end

  describe "retrieve_facets?" do
    it "returns true by default when settings is nil" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance"
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_facets?).to be true
    end

    it "returns true when settings is empty" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_facets?).to be true
    end

    it "returns true when facets setting is true" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {"facets" => true}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_facets?).to be true
    end

    it "returns false when facets setting is false" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {"facets" => false}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_facets?).to be false
    end
  end

  describe "retrieve_holdings?" do
    it "returns true by default when settings is nil" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance"
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_holdings?).to be true
    end

    it "returns true when settings is empty" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_holdings?).to be true
    end

    it "returns true when holdings setting is true" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {"holdings" => true}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_holdings?).to be true
    end

    it "returns false when holdings setting is false" do
      request_hash = {
        "uid" => "test",
        "start" => 0,
        "count" => 10,
        "field_tree" => {},
        "facets" => {},
        "sort" => "relevance",
        "settings" => {"holdings" => false}
      }
      data_store = Spectrum::Request::DataStore.new(request_hash)
      expect(data_store.retrieve_holdings?).to be false
    end
  end
end
