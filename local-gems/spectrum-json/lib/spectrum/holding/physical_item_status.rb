module Spectrum
  class Holding
    class PhysicalItemStatus
      attr_reader :text
      def initialize(text)
        @text = text
      end
      ["intent", "icon"].each do |name|
        define_method(name) {}
      end
      def to_h
        {
          text: @text,
          intent: intent,
          icon: icon
        }
      end

      def self.for(item)
        return Success.new("Reading Room use only") if item.can_reserve?
        workflow_status_label = ::Spectrum::Entities::AlmaWorkflowStatusLabels.value(item.process_type)
        return Error.new("Unavailable") if item.process_type == "WORK_ORDER_DEPARTMENT" && item.in_game?
        case item.process_type
        when nil
          if item.in_unavailable_temporary_location?
            Error.new("Unavailable")
          else
            Success.new(Text::AvailableText.for(item).to_s)
          end
        when "LOAN"
          Warning.new(Text::CheckedOutText.new(item).to_s)
        when "MISSING"
          Error.new(workflow_status_label)
        when "ILL"
          Error.new(workflow_status_label)
        else
          Warning.new(workflow_status_label)
        end
      end

      class Success < self
        def intent
          "success"
        end

        def icon
          "check_circle"
        end

        def base_text
          "On shelf"
        end
      end

      class Warning < self
        def intent
          "warning"
        end

        def icon
          "warning"
        end
      end

      class Error < self
        def intent
          "error"
        end

        def icon
          "error"
        end
      end
    end
  end
end
