require_relative "../../spec_helper"
describe Spectrum::Entities::AlmaWorkflowStatusLabels do
  context "::options" do
    before(:each) do
      Spectrum::Entities::AlmaWorkflowStatusLabels.configure("spec/fixtures/alma_workflow_status_labels.json")
    end
    it "returns appropriate display text for a library code" do
      expect(described_class.value("HOLDSHELF")).to eq("On hold shelf")
    end
  end
end
