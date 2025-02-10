module AlmaRestClient
  class Client
    [:get, :post, :delete, :put].each do |name|
      old_method = instance_method(name)
      define_method(name) do |url, options = {}|
        response = nil
        duration = Benchmark.realtime do
          response = old_method.bind(self).(url, options)
        end
        Metrics(:api_response_duration_seconds) do |metric|
          metric.observe(duration, labels: {source: "alma"})
        end
        response
      end
    end
  end
end
