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
                  barcode: "none",
                  action: "get-this",
                  record: @holding.mms_id,
                  datastore: @holding.mms_id
                }
              },
              {
                text: "Use Get This to request through Interlibrary Loan"
              },
              {
                text: "In Process",
                intent: "warning",
                icon: "warning"
              }

            ]
          ]
        end
      end
    end
  end
end
