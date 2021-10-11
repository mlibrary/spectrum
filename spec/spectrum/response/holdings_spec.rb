require_relative '../../rails_helper'

describe Spectrum::Response::Holdings, "integrations" do
  def stub_http(id:,getHoldings:,solr:)
    stub_request(:get, "http://localhost/solr/biblio/select?q=id:#{id}&wt=ruby").to_return(body: solr, status: 200, headers: {content_type: 'application/json'})
    stub_alma_get_request(url: "bibs/#{id}/loans", output: {"total_record_count": 0}.to_json, query: {limit: 100, offset: 0})
  end
  before(:each) do
    
    @source_dbl = double('Source', url: 'http://localhost/solr/biblio', driver: 'RSolr')

  end
  subject do
    described_class.new(@source_dbl, @request)
  end
  it "returns expected array for single normal holding" do
    @request = Spectrum::Request::Holdings.new({id: '990020578280206381'}) 
    solr = File.read('./spec/fixtures/solr_bib_alma.json')
    getHoldings = File.read('./spec/fixtures/faculty_careers_getHoldings.json')
    stub_http(id: @request.id, getHoldings: getHoldings, solr: solr)

    output = JSON.parse(File.read('./spec/fixtures/enhance_faculty_careers_output.json'), symbolize_names: true)
    expect(subject.renderable).to eq(output)
  end
  #it "returns expected array for uplinks" do
    #@request = Spectrum::Request::Holdings.new({id: '005061252'}) 
    #solr = File.read('./spec/fixtures/uplinks_solr.json')
    #getHoldings = File.read('./spec/fixtures/uplinks_getHoldings.json')
    #stub_http(id: @request.id, getHoldings: getHoldings, solr: solr)

    #output = JSON.parse(File.read('./spec/fixtures/uplinks_output.json'), symbolize_names: true)
    #expect(subject.renderable).to eq(output)
  #end
  #it "returns expected array for downlinks" do
    #@request = Spectrum::Request::Holdings.new({id: '004759908'}) 
    #solr = File.read('./spec/fixtures/downlinks_solr.json')
    #getHoldings = File.read('./spec/fixtures/downlinks_getHoldings.json')
    #stub_http(id: @request.id, getHoldings: getHoldings, solr: solr)

    #output = JSON.parse(File.read('./spec/fixtures/downlinks_output.json'), symbolize_names: true)
    #expect(subject.renderable).to eq(output)
  #end
end
