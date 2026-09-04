require "json"

RSpec.describe SpectrumMcp::Tools::GetRecord do
  it "fetches a single record from the mirlyn (catalog) datastore" do
    response_body = {
      data: {uid: "990000000001", fields: [{uid: "title", name: "Title", value: "Psychology 101"}]},
      source: "mirlyn",
      focus: "mirlyn"
    }

    stub = stub_request(:get, "#{SPECTRUM_BASE_URL}/spectrum/mirlyn/record/990000000001")
      .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: response_body.to_json)

    result = described_class.call(datastore: "Catalog", id: "990000000001", server_context: nil)

    expect(stub).to have_been_requested
    expect(result.error?).to be false
    parsed = JSON.parse(result.content.first[:text])
    expect(parsed["data"]["uid"]).to eq("990000000001")
  end

  it "percent-encodes ids that contain special characters" do
    stub = stub_request(:get, "#{SPECTRUM_BASE_URL}/spectrum/mirlyn/record/10.1000%2Fxyz")
      .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: {data: {}}.to_json)

    described_class.call(datastore: "Catalog", id: "10.1000/xyz", server_context: nil)

    expect(stub).to have_been_requested
  end

  it "returns an error response when Spectrum fails" do
    stub_request(:get, "#{SPECTRUM_BASE_URL}/spectrum/mirlyn/record/missing").to_return(status: 404, body: "not found")

    result = described_class.call(datastore: "Catalog", id: "missing", server_context: nil)

    expect(result.error?).to be true
    expect(result.content.first[:text]).to include("404")
  end
end
