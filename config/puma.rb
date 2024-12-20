require "dotenv"
Dotenv.load(File.expand_path("../../.env", __FILE__))

ENV["RAILS_RELATIVE_URL_ROOT"] ||= "http://localhost:3000"

environment "production"
threads 4, 32

# Use tcp as the http server (apache) is on a different host.
if ENV["PUMA_BIND"]
  # If the bind string is in the environment.
  bind ENV["PUMA_BIND"]
elsif ENV["RAILS_RELATIVE_URL_ROOT"] == "http://localhost:3000"
  # If it's more of a development environment
  bind "tcp://127.0.0.1:3000"
elsif ENV["PUMA_PRIVATE_IP"] && ENV["PUMA_PORT"]
  # Bind to the private network address
  private_ip = Socket.ip_address_list.find do |ip|
    ip.ip_address.start_with?("10.")
  end.ip_address
  bind "tcp://#{private_ip}:#{ENV["PUMA_PORT"]}"
elsif ENV["BIND_IP"] && ENV["BIND_PORT"]
  bind "tcp://#{ENV["BIND_IP"]}:#{ENV["BIND_PORT"]}"
end

pidfile ENV.fetch("PUMA_PIDFILE", File.expand_path("../../log/search-puma.pid", __FILE__))

# on_restart do
#   Code to run before doing a restart. This code should
#   close log files, database connections, etc.
# end

workers ENV["PUMA_WORKERS"] || 2
worker_timeout 120
# on_worker_boot do
#   Code to run when a worker boots to setup the process before booting
#   ActiveSupport.on_load(:active_record) do
#     ActiveRecord::Base.establish_connection
#   end
# end

# before_fork do
#   ActiveRecord::Base.connection_pool.disconnect!
# end

if ENV["PUMA_CONTROL_APP"]
  activate_control_app ENV["PUMA_CONTROL_APP"], {no_token: true}

  if ENV["PROMETHEUS_EXPORTER_URL"]
    Bundler.require :yabeda

    plugin :yabeda
    plugin :yabeda_prometheus
    prometheus_exporter_url ENV["PROMETHEUS_EXPORTER_URL"]

    on_worker_boot do
      # Prometheus::Middleware::Collector.new has side effects that registers
      # metrics.  If they are already loaded it raises an exception.
      if Prometheus::Client.registry.exist?(:http_server_requests_total)
        Prometheus::Client.registry.unregister(:http_server_requests_total)
        Prometheus::Client.registry.unregister(:http_server_request_duration_seconds)
        Prometheus::Client.registry.unregister(:http_server_exceptions_total)
      end

      uri = URI(ENV["PROMETHEUS_EXPORTER_URL"])
      ObjectSpace.each_object(TCPServer).each do |server|
        next if server.closed?
        family, port, host, _ = server.addr
        if family == "AF_INET" && port == uri.port && host == uri.host
          server.close
        end
      end
    end

    if (monitoring_dir = ENV["PROMETHEUS_MONITORING_DIR"])
      on_prometheus_exporter_boot do
        # http_server_exceptions_total was generating invalid metrics for us
        if Prometheus::Client.registry.exist?(:http_server_exceptions_total)
          Prometheus::Client.registry.unregister(:http_server_exceptions_total)
        end
        # In clustered mode, the worker processes get these registered, but the coordinating process does not.
        # Ending up in these stats being collected, but not reported.
        unless Prometheus::Client.registry.exist?(:http_server_requests_total)
          # These are copied from Prometheus::Middleware::Collector#init_request_metrics
          # and  Prometheus::Middleware::Collector#init_exception_metrics
          Prometheus::Client.registry.counter(
            :http_server_requests_total,
            docstring: "The total number of HTTP requests handled by the Rack application.",
            labels: %i[code method path]
          )
          Prometheus::Client.registry.histogram(
            :http_server_request_duration_seconds,
            docstring: "The HTTP response duration of the Rack application.",
            labels: %i[method path]
          )
          # http_server_exceptions_total was generating invalid metrics for us.
          # Prometheus::Client.registry.histogram(
          #   :http_server_exceptions_total,
          #   docstring: "The total number of exceptions raised by the Rack application.",
          #   labels: [:exception]
          # )

          Dir[File.join(monitoring_dir, "*.bin")].each do |file_path|
            File.unlink(file_path)
          end

          Yabeda.configure!
        end
      end

      before_fork do
        Prometheus::Client.config.data_store =
          Prometheus::Client::DataStores::DirectFileStore.new(dir: monitoring_dir)
      end
    end

  end
end
