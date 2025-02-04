module Prometheus
  module Middleware
    class RegisteredCollector < Collector
      protected

      def init_request_metrics
        requests_name = :"#{@metrics_prefix}_requests_total"
        durations_name = :"#{@metrics_prefix}_request_duration_seconds"
        @requests = @registry.get(requests_name) || FakeMetrics
        @durations = @registry.get(durations_name) || FakeMetrics
      end

      def init_exception_metrics
        exceptions_name = :"#{@metrics_prefix}_exceptions_total"
        @exceptions = @registry.get(exceptions_name) || FakeMetrics
      end

      class FakeMetrics
        def self.increment(*)
        end

        def self.observe(*)
        end
      end
    end
  end
end
