module Spectrum
  module Presenters
    module HoldingPresenter
      class EmptyHoldingPresenter < Base
        def type
          "physical"
        end

        def caption
          "Availability"
        end

        def headings
          ["Action", "Description", "Status"]
        end

        def rows
          [
            [
              {
                text: "Get This",
                to: {
                  barcode: @holding.barcode,
                  action: "get-this",
                  record: @holding.mms_id,
                  datastore: @holding.mms_id
                }
              },
              {
                text: "Use Get This to request through Interlibrary Loan"
              },
              Spectrum::Holding::PhysicalItemStatus::Warning.new(@holding.status).to_h
            ]
          ]
        end
      end
    end
  end
end
