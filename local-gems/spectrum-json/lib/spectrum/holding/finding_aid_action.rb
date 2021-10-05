module Spectrum
  class Holding
    class FindingAidAction < Action
      def self.match?(item)
        item.record_has_finding_aid
      end
      def self.label
        'Finding Aid'
      end
     
      def finalize
        {
          text: label,
          href: @item.finding_aid.link
        }
      end
    end
  end
end
