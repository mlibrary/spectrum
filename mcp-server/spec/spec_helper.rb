require "webmock/rspec"

WebMock.disable_net_connect!

SPECTRUM_BASE_URL = ENV.fetch("SPECTRUM_BASE_URL", "http://localhost:3000")

# The tool classes build their `datastore` enum from the live datastore list
# when they're first loaded, so that lookup has to be stubbed before requiring them.
WebMock.stub_request(:get, "#{SPECTRUM_BASE_URL}/spectrum").to_return(
  status: 200,
  headers: {"Content-Type" => "application/json"},
  body: {
    response: [
      {uid: "mirlyn", metadata: {name: "Catalog"}},
      {uid: "databases", metadata: {name: "Databases"}},
      {uid: "onlinejournals", metadata: {name: "Online Journals"}},
      {uid: "primo", metadata: {name: "Articles"}},
      {uid: "website", metadata: {name: "Guides and more"}}
    ]
  }.to_json
)

require_relative "../lib/spectrum_mcp/server"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
