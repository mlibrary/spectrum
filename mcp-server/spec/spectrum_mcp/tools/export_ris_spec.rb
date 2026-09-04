require "json"

RSpec.describe SpectrumMcp::Tools::ExportRis do
  it "exports RIS data for records from the mirlyn (catalog) datastore" do
    ris_body = "TY  - BOOK\r\nTI  - Psychology 101\r\nER  -\r\n"

    stub = stub_request(:post, "#{SPECTRUM_BASE_URL}/spectrum/file")
      .with { |request| JSON.parse(request.body)["mirlyn"]["records"] == ["990000000001"] }
      .to_return(status: 200, headers: {"Content-Type" => "application/x-research-info-systems"}, body: ris_body)

    result = described_class.call(datastore: "Catalog", ids: ["990000000001"], server_context: nil)

    expect(stub).to have_been_requested
    expect(result.error?).to be false
    expect(result.content.first[:text]).to eq(ris_body)
  end

  it "passes along an optional base_url" do
    stub = stub_request(:post, "#{SPECTRUM_BASE_URL}/spectrum/file")
      .with { |request| JSON.parse(request.body)["mirlyn"]["base_url"] == "https://search.lib.umich.edu" }
      .to_return(status: 200, body: "TY  - BOOK\r\nER  -\r\n")

    described_class.call(datastore: "Catalog", ids: ["990000000001"], base_url: "https://search.lib.umich.edu", server_context: nil)

    expect(stub).to have_been_requested
  end

  it "returns an error response when Spectrum fails" do
    stub_request(:post, "#{SPECTRUM_BASE_URL}/spectrum/file").to_return(status: 500, body: "boom")

    result = described_class.call(datastore: "Catalog", ids: ["990000000001"], server_context: nil)

    expect(result.error?).to be true
    expect(result.content.first[:text]).to include("500")
  end
end
