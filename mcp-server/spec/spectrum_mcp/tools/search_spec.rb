require "json"

RSpec.describe SpectrumMcp::Tools::Search do
  it "searches the mirlyn (catalog) datastore and returns the JSON response" do
    response_body = {
      request: {uid: "mirlyn", raw_query: "psychology"},
      response: [{uid: "990000000001", fields: [{uid: "title", name: "Title", value: "Psychology 101"}]}],
      total_available: 1
    }

    stub = stub_request(:post, "#{SPECTRUM_BASE_URL}/spectrum/mirlyn")
      .with { |request| JSON.parse(request.body)["raw_query"] == "psychology" && JSON.parse(request.body)["uid"] == "mirlyn" }
      .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: response_body.to_json)

    result = described_class.call(datastore: "Catalog", query: "psychology", server_context: nil)

    expect(stub).to have_been_requested
    expect(result.error?).to be false
    parsed = JSON.parse(result.content.first[:text])
    expect(parsed["total_available"]).to eq(1)
    expect(parsed["response"].first["uid"]).to eq("990000000001")
  end

  it "passes facet filters through to Spectrum" do
    stub = stub_request(:post, "#{SPECTRUM_BASE_URL}/spectrum/mirlyn")
      .with { |request| JSON.parse(request.body)["facets"] == {"format" => ["Book", "CDROM"]} }
      .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: {response: []}.to_json)

    result = described_class.call(datastore: "Catalog", query: "psychology", filters: {"format" => ["Book", "CDROM"]}, server_context: nil)

    expect(stub).to have_been_requested
    expect(result.error?).to be false
  end

  it "returns an error response when Spectrum fails" do
    stub_request(:post, "#{SPECTRUM_BASE_URL}/spectrum/mirlyn").to_return(status: 500, body: "boom")

    result = described_class.call(datastore: "Catalog", query: "psychology", server_context: nil)

    expect(result.error?).to be true
    expect(result.content.first[:text]).to include("500")
  end
end
