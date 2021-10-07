module Spectrum
  class Holding
    class NoAction < Action
      def self.match?(item)
        return true if item.barcode.nil?
        return true if ['06','07'].include?(item.item_policy)

        case item.library
        when 'AAEL'
          ['05'].include?(item.item_policy)
        when 'FINE'
          ['03','05'].include?(item.item_policy)
        when 'FLINT'
          ['05','10'].include?(item.item_policy)
        when 'MUSM'
          ['03'].include?(item.item_policy)
        when 'HATCH'
          item.location == 'PAPY'
        when 'BTSA'
          ['08'].include?(item.item_policy)
        when 'CSCAR'
          ['08'].include?(item.item_policy)
        when 'DHCL'
          ['BOOK', 'OVR'].include?(item.location) && item.item_policy == '08'
        else
          false
        end
      end
      def self.label
        'N/A'
      end
      def finalize
        { text: label }
      end
    end
  end
end
