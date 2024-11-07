require "net/http"

RSpec.describe "Standalone Prometheus Exporter" do
  before(:each) do
    cmd = %w[
      bundle exec puma
        -b tcp://127.0.0.1:9222
        -C spec/configs/puma_standalone.rb
        spec/configs/standalone.ru
    ]
    ENV["TEST_RUNNER_PID"] = Process.pid.to_s
    proceed = false
    trap(:USR1) { proceed = true }
    @pid = fork do
      $stdout.reopen("/dev/null", "w")
      $stderr.reopen("/dev/null", "w")
      exec(*cmd)
    end
    Timeout::timeout(10) { until proceed do sleep(0.1) end }
  end

  after(:each) do
    Process.kill "INT", @pid 
    Process.wait @pid
  end

  it 'serves app on configured port' do
    res = get 9222, "/"
    expect(res.body).to match(/Lobstericious/)
  end

  it 'serves metrics on exporter url' do
    res = get 9394, "/metrics"
    expect(res.body).to match(/^# TYPE puma_workers gauge/)
  end

  it 'serves metrics after hot restart' do
    Process.kill("USR2", @pid)
    sleep 0.5
    res = get 9394, "/metrics"
    expect(res.body).to match(/^# TYPE puma_workers gauge/)
  end

  it 'serves metrics after phased restart' do
    Process.kill("USR1", @pid)
    sleep 0.5
    res = get 9394, "/metrics"
    expect(res.body).to match(/^# TYPE puma_workers gauge/)
  end

  it 'serves metrics after 2 phased restarts' do
    Process.kill("USR1", @pid)
    sleep 0.5
    res = get 9394, "/metrics"
    expect(res.body).to match(/^# TYPE puma_workers gauge/)
    Process.kill("USR1", @pid)
    sleep 0.5
    res = get 9394, "/metrics"
    expect(res.body).to match(/^# TYPE puma_workers gauge/)
  end

  def get(port, path = "/")
    retries = 3
    begin
      Net::HTTP.start("127.0.0.1", port, open_timeout: 3) do |http|
        req = Net::HTTP::Get.new path
        return http.request req
      end
    rescue Errno::ECONNREFUSED
      if retries > 0
        retries -= 1
        sleep 1
        retry
      else
        raise "Connection failed too many times for http://127.0.0.1:#{port}#{path}"
      end
    end
    nil
  end
end
