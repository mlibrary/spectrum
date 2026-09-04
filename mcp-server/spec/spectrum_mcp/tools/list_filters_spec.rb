require "json"

RSpec.describe SpectrumMcp::Tools::ListFilters do
  it "lists the filters available for the mirlyn (catalog) datastore" do
    stub_request(:get, "#{SPECTRUM_BASE_URL}/spectrum").to_return(
      status: 200,
      headers: {"Content-Type" => "application/json"},
      body: {
        response: [
          {
            uid: "mirlyn",
            metadata: {name: "Catalog"},
            facets: [
              {
                uid: "format",
                metadata: {name: "Format", short_desc: "Format"},
                type: "multiselect",
                values: [
                  {value: "Book", name: "Book", count: 100},
                  {value: "CDROM", name: "CDROM", count: 10}
                ]
              }
            ]
          }
        ]
      }.to_json
    )

    result = described_class.call(datastore: "Catalog", server_context: nil)

    expect(result.error?).to be false
    filters = JSON.parse(result.content.first[:text])
    expect(filters.map { |f| f["name"] }).to eq(["format"])
    expect(filters.first["values"]).to eq([{"value" => "Book", "count" => 100}, {"value" => "CDROM", "count" => 10}])
    expect(filters.first["more_values"]).to be false
  end

  it "caps the number of values returned and flags when there are more" do
    values = (1..30).map { |n| {value: "v#{n}", name: "v#{n}", count: n} }
    stub_request(:get, "#{SPECTRUM_BASE_URL}/spectrum").to_return(
      status: 200,
      headers: {"Content-Type" => "application/json"},
      body: {response: [{uid: "mirlyn", metadata: {name: "Catalog"}, facets: [{uid: "subject", metadata: {name: "Subject"}, type: "multiselect", values: values}]}]}.to_json
    )

    result = described_class.call(datastore: "Catalog", server_context: nil)

    filters = JSON.parse(result.content.first[:text])
    expect(filters.first["values"].size).to eq(20)
    expect(filters.first["more_values"]).to be true
  end

  it "returns an error response when Spectrum fails" do
    stub_request(:get, "#{SPECTRUM_BASE_URL}/spectrum").to_return(status: 500, body: "boom")

    result = described_class.call(datastore: "Catalog", server_context: nil)

    expect(result.error?).to be true
    expect(result.content.first[:text]).to include("500")
  end
end
