require_relative '../../rails_helper'
describe Spectrum::Entities::AlmaHold do
  before(:each) do
    @params = {
      doc_id: 'mms_id',
      holding_id: 'holding_id',
      item_id: 'item_id',
      patron_id: 'patron_id',
      pickup_location: 'pickup_location',
      last_interest_date: '2022-01-01',
    }

    @hold_body = {
          "request_type" => "HOLD",
          "pickup_location_type" => "LIBRARY",
          "pickup_location_library" => "pickup_location",
          "pickup_location_institution" => "01UMICH_INST",
          "last_interest_date" => "2022-01-01",
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#item_hold_url" do
    it "returns appropriate string" do
      expect(subject.item_hold_url).to eq( "/bibs/mms_id/holdings/holding_id/items/item_id/requests?user_id=patron_id")
    end
  end
  context "#item_hold_body" do
    it "returns appropriate string" do
      expect(subject.item_hold_body).to eq(@hold_body)
    end
  end
  context "after create!" do
    before(:each) do
      @alma_response = JSON.parse(File.read("./spec/fixtures/get_this/alma_hold_error_response.json"))
      @code = 500
    end
    subject do
      stub_alma_post_request(url: "bibs/mms_id/holdings/holding_id/items/item_id/requests", input: @hold_body.to_json, output: @alma_response.to_json, query: {user_id: "patron_id"}, status: @code)
      described_class.new(**@params).create!
    end
    context "#success?" do
      it "is false when not successful" do
        expect(subject.success?).to eq(false)
      end
      it "is false when not success but bad output" do
        @code = 200
        expect(subject.success?).to eq(false)
      end
      it "is true when successful" do
        @code = 200
        @alma_response = JSON.parse(File.read("./spec/fixtures/get_this/alma_hold_success_response.json"))
        expect(subject.success?).to eq(true)
      end
    end
    context "#error?" do
      it "is true when there is an error" do
        expect(subject.error?).to eq(true)
      end
      it "is false when there is a success" do
        @code = 200
        @alma_response = JSON.parse(File.read("./spec/fixtures/get_this/alma_hold_success_response.json"))
        expect(subject.error?).to eq(false)
      end
    end
    context "#error_code" do
      it "returns the appropriate error code" do
        expect(subject.error_code).to eq(["60328"])
      end
    end
    context "#error_message" do
      it "returns the appropriate error code" do
        expect(subject.error_message).to eq(["Physical item not found for request: blah"])
      end
    end
  end

end
