require "json"

RSpec.describe "tools/list" do
  let(:server) { SpectrumMcp.build_server }

  def tools_list
    JSON.parse(server.handle_json({jsonrpc: "2.0", id: 1, method: "tools/list"}.to_json))
  end

  it "lists the three spectrum tools" do
    names = tools_list["result"]["tools"].map { |tool| tool["name"] }
    expect(names).to contain_exactly("spectrum_search", "spectrum_get_record", "spectrum_export_ris")
  end

  it "describes the search tool's required arguments" do
    tool = tools_list["result"]["tools"].find { |t| t["name"] == "spectrum_search" }
    expect(tool["inputSchema"]["required"]).to eq(["focus", "query"])
    expect(tool["inputSchema"]["properties"]["focus"]["enum"]).to include("mirlyn")
  end

  it "describes the get_record tool's required arguments" do
    tool = tools_list["result"]["tools"].find { |t| t["name"] == "spectrum_get_record" }
    expect(tool["inputSchema"]["required"]).to eq(["focus", "id"])
  end

  it "describes the export_ris tool's required arguments" do
    tool = tools_list["result"]["tools"].find { |t| t["name"] == "spectrum_export_ris" }
    expect(tool["inputSchema"]["required"]).to eq(["focus", "ids"])
  end
end
