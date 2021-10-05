module Spectrum
  class Holding
    class PhysicalItemDescription
      attr_reader :temp_location, :description
      def initialize(item)
        @item = item
        @description = item.description
      end
      def to_h
        { format_type => value }
      end

      def self.for(item)
        has_description =  !(item.description.nil? || item.description.empty?)
        in_non_reserves_temp_location = item.temp_location? && !item.in_reserves? && !item.in_unavailable_temporary_location?
        if in_non_reserves_temp_location && has_description
          TemporaryWithDescription.new(item)
        elsif in_non_reserves_temp_location
          TemporaryNoDescription.new(item)
        elsif has_description
          DescriptionNotTemporary.new(item)
        else #Not Temporary and No Description
          PhysicalItemDescription.new(item)
        end
      end

      private

      def value
        ''
      end
      
      def format_type
        :text
      end

      def temp_location_string
        "In a Temporary Location"
      end

      class TemporaryWithDescription < PhysicalItemDescription
        def value
          "<div>#{@description}</div><div>#{temp_location_string}</div>"
        end
        def format_type
          :html
        end
      end

      class TemporaryNoDescription < PhysicalItemDescription
        def value
          temp_location_string
        end
      end
      class DescriptionNotTemporary < PhysicalItemDescription
        def value
          @description
        end
      end

      private_constant :TemporaryWithDescription
      private_constant :TemporaryNoDescription
      private_constant :DescriptionNotTemporary
    end
  end
end

