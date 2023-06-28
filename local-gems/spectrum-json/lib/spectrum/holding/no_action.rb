module Spectrum
  class Holding
    class NoAction < Action
      def self.match?(item)
        return true if item.barcode.nil?
        return true if item.library == "SHAP" && item.location == "GAME" && item.process_type == "WORK_ORDER_DEPARTMENT"
        case item.item_policy
        when "05"
          true if item.library == "AAEL"
        when "10"
          true if item.library == "FLINT"
        else
          false
        end
      end

      def self.label
        "N/A"
      end

      def finalize
        {text: label}
      end
    end
  end
end
