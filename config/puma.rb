require "dotenv"
Dotenv.load(File.expand_path(File.join("..", ".env"), __dir__))

if (log_file_name = ENV.fetch("LOG_FILE", false))
  stdout_redirect(log_file_name, log_file_name, true)
end

ENV["RAILS_RELATIVE_URL_ROOT"] ||= "http://localhost:3000"

environment "production"
threads ENV.fetch("PUMA_THREADS_MIN", 4), ENV.fetch("PUMA_THREADS_MAX", 32)

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

Bundler.require :metrics
Metrics.load_config
Metrics.configure_puma(self)

