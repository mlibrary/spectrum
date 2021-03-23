ENV['RAILS_RELATIVE_URL_ROOT'] ||= 'http://localhost:3000'

environment 'production'
threads 4, 32
# Bind to the private network address
# Use tcp as the http server (apache) is on a different host.
bind 'tcp://127.0.0.1:3000' if ENV['RAILS_RELATIVE_URL_ROOT'] == 'http://localhost:3000'

pidfile File.expand_path('../../log/search-puma.pid', __FILE__)

on_restart do
# Code to run before doing a restart. This code should
# close log files, database connections, etc.
end

workers ENV['PUMA_WORKERS'] || 2
worker_timeout 120
#on_worker_boot do
  # Code to run when a worker boots to setup the process before booting
  #ActiveSupport.on_load(:active_record) do
    #ActiveRecord::Base.establish_connection
  #end
#end

#before_fork do
  #ActiveRecord::Base.connection_pool.disconnect!
#end

activate_control_app ENV['PUMA_CONTROL_APP'], {no_token: true} if ENV['PUMA_CONTROL_APP']
