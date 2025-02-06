module AlmaRestClient
  class Client
    [:get, :post, :delete, :put].each do |name|
      old_method = instance_method(name)
      define_method(name) do |url, options = {}|
        @metrics ||= Prometheus::Client.registry.get(:api_response_duration_seconds)
        response = nil
        duration = Benchmark.realtime do
          response = old_method.bind(self).(url, options)
        end
        @metrics.observe(duration, labels: {source: "alma"})
        response
      end
    end
  end
end
