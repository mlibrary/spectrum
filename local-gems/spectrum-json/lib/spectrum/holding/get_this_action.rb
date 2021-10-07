module Spectrum
  class Holding
    class GetThisAction < Action
      def self.label
        'Get This'
      end
      #label 'Get This' 

      def self.match?(item)
        # Tim's most current logic says yes already.
        return true if item.can_request?

        # Apply the snapshot of Tim's logic from 9/1
        ret = from_process_status(item)
        return false if item.sub_library == 'FVL'
        return false if item.sub_library == 'SPEC'
        return false if item.sub_library == 'BENT' && item.collection == 'ELEC'
        return false if item.sub_library == 'CLEM' && item.collection == 'ELEC'
        return false if item.collection  == 'PAPY' && item.sub_library.match(/^(SPEC|HATCH)/)
        ret
      end

      def self.from_process_status(item)
        ret = item_default_match(item)
        return ret if item.item_process_status.nil? || item.item_process_status.empty?

        ps_entry = process_status_map[item.item_process_status]
        return false unless ps_entry
        ret = ps_entry[1]
        return false if item.item_process_status.match(/NA|CL/) && item.item_expected_arrival_date
        if item.item_status == '08'
          return true unless item.sub_library.match(/BSTA|CSCAR/)
          return false if item.sub_library == 'DHCL' && !(item.collection.match(/BOOK|OVR/))
        end

        return true if item.recall_due_date
        return true if item.due_date && item.bor_status == '11' && item.loan_status == 'A'
        ret
      end

      def self.process_status_map
        {
          'LO' => ['Missing', 1],
          'CR' => ['Missing', 1],
          'PD' => ['Missing', 1],
          'SP' => ['In Special Collections', 0],
          'SW' => ['Scholars Workstation.Ask at IC', 0],
          'FO' => ['On Reserve at Foster Library', 0],
          'WE' => ['On Reserve at Weill Reading Rm', 0],
          'DW' => ['Documents Workstation', 0],
          'NE' => ['On Loan to NELP-Ask at GL Circ', 0],
          'LA' => ['At Labeling', 0],
          'LB' => ['Sent to Labeling', 0],
          'IP' => ['In process', 0],
          'SC' => ['Send to Cataloging', 0],
          'CT' => ['Cataloging', 0],
          'TE' => ['Technical Department', 0],
          'MI' => ['Missing', 1],
          'NA' => ['Not arrived', 0],
          'SU' => ['Subject and classification', 0],
          'CA' => ['Cancelled', 0],
          'NP' => ['Not Published', 0],
          'DP' => ['Remote Storage', 0],
          'MM' => ['On Loan for Scanning', 0],
          'AR' => ['Askwith Reserve - Ask at Desk', 0],
          'UG' => ['UGL - Not Available', 0],
          'NL' => ['No Longer Available', 0],
          'WN' => ['Withdrawn', 0],
          'HN' => ['No Longer Available', 0],
          'DC' => ['Unavailable - Ask at ILL', 0],
          'DX' => ['Sent for Scanning', 0],
          'DY' => ['On Loan for Scanning (DCU)', 0],
          'DZ' => ['Sent from Scanning', 0],
          'NS' => ['NSDS Lab (Documents Center)', 0],
          'EO' => ['Electronic Access Only', 0],
          'SD' => ['SDR', 0],
          'DU' => ['Duplicate to be Withdrawn', 0],
          'SA' => ['Slavic In Process', 0],
          'SH' => ['Slavic In Process', 0],
          'JT' => ['Access at Jim Toy Library', 0],
          'MC' => ['Access at Mark Chesler Library', 0],
          'CX' => ['Sent to Conservation', 0],
          'CY' => ['In Conservation', 0],
          'CZ' => ['Returned from Conservation', 0],
          'NR' => ['New Release', 0],
          'CN' => ['Not Available', 0],
          'DH' => ['Access at Donald Hall Collect', 0],
          'MG' => ['Missing 2', 0],
          'FA' => ['Reading Room Use Only', 0],
          'PF' => ['At Bindery', 0],
          'CS' => ['Not available', 0],
          'AS' => ['Asia Library Cataloging', 0],
          'IS' => ['Int. Studies Cataloging', 0],
          'DJ' => ['Final Processing. Please ask staff or use the "Get This" button.', 0],
          'SE' => ['SE Asia In Process-Hatcher', 0],
          'CC' => ['Closed shelving. Please use "Get This" to request materials.', 0],
          '01' => ['Loan 1', 0],
          '02' => ['Loan 2', 0],
          '03' => ['Loan 3', 0],
          '04' => ['Loan 4', 0],
          '05' => ['Loan 5', 0],
          '06' => ['4 Hour Loan', 0],
          '07' => ['2 Hour Loan', 0],
          '08' => ['No Loan', 0],
          '09' => ['No Loan', 0],
          '10' => ['Loan 10', 0],
          '11' => ['6 Hour Loan', 0],
          '12' => ['8 Hour Loan', 0],
          '13' => ['Loan 13', 0],
        }
      end

      def self.item_default_match(item)
        return false unless item.item_status
        return false unless item.sub_library
        return false if item.item_status.match(/0[678]/)
        return false if item.sub_library == 'AAEL'  && item.item_status.match(/0[45]/)
        return false if item.sub_library == 'FINE'  && item.item_status.match(/0[345]/)
        return false if item.sub_library == 'FLINT' && item.item_status.match(/0[45]|10/)
        return false if item.sub_library == 'MUSM'  && item.item_status == '03'
        return false if item.sub_library == 'SCI' && item.item_status.match(/0[45]/)
        true
      end

      def finalize
        super.merge(
          to: {
            barcode: @item.barcode,
            action: 'get-this',
            record: @item.doc_id,
            datastore: @item.doc_id,
          }
        )
      end
    end
  end
end
