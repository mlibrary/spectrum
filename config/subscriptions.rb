ActiveSupport::Notifications.subscribe("track.rack_attack") do |event|
  next unless event.payload[:request].env["rack.attack.matched"] == "haz_cookie"
  Metrics(:cookie_size_bytes) do |metric|
    metric.observe(event.payload[:request].env["HTTP_COOKIE"].bytesize)
  end
end

ActiveSupport::Notifications.subscribe("cookie_purge.spectrum_json") do |event|
  Metrics(:cookie_purges_total) do |metric|
    metric.increment
  end
end

ActiveSupport::Notifications.subscribe("rsolr_exception.spectrum_search_engine_solr") do |event|
  Metrics.logger.error { ([event.payload[:exception].message] + event.payload[:exception].backtrace).join($/) }
  Metrics(:exceptions_total) do |metric|
    metric.increment(labels: {source: event.payload[:source_id]})
  end
end

ActiveSupport::Notifications.subscribe("primo_exception.spectrum_search_engine_primo") do |event|
  Metrics.logger.error { ([event.payload[:exception].message] + event.payload[:exception].backtrace).join($/) }
  Metrics(:exceptions_total) do |metric|
    metric.increment(labels: {source: event.payload[:source_id]})
  end
end

ActiveSupport::Notifications.subscribe("libkey_exception.spectrum_search_engine_primo") do |event|
  Metrics.logger.error { ([event.payload[:exception].message] + event.payload[:exception].backtrace).join($/) }
  Metrics(:exceptions_total) do |metric|
    metric.increment(labels: {source: event.payload[:source_id]})
  end
end

ActiveSupport::Notifications.subscribe("email_exception.spectrum_json") do |event|
  Metrics.logger.error { ([event.payload[:exception].message] + event.payload[:exception].backtrace).join($/) }
  Metrics(:exceptions_total) do |metric|
    metric.increment(labels: {source: "email-export"})
  end
end

ActiveSupport::Notifications.subscribe("text_exception.spectrum_json") do |event|
  Metrics.logger.error { ([event.payload[:exception].message] + event.payload[:exception].backtrace).join($/) }
  Metrics(:exceptions_total) do |metric|
    metric.increment(labels: {source: "text-export"})
  end
end

ActiveSupport::Notifications.subscribe("primo_search.spectrum_search_engine_primo") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.payload[:duration], labels: {
      source: event.payload[:source_id],
      query_word_count: event.payload[:params].keyword_count,
      query_has_booleans: event.payload[:params].has_booleans?,
      query_has_quoted_phrases: event.payload[:params].has_quotes?,
      response_total_items_magnitude: event.payload[:response].total_items_magnitude
    })
  end

  event.payload[:response].docs.each do |doc|
    begin
      libkey_link = doc["fullTextFile"] || doc["bestIntegratorLink"]&.fetch("bestLink", nil)
      primo_link = if doc.link_to_resource?
        doc.link_to_resource
      else
        "https://mgetit.lib.umich.edu/resolve?#{doc.openurl}"
      end
      Metrics.logger.info {"EZproxy:\tprimo-#{doc["id"]}\t#{libkey_link}"} if libkey_link
      Metrics.logger.info {"EZproxy:\tprimo-#{doc["id"]}\t#{primo_link}"} if primo_link
    rescue
    end
  end
end

ActiveSupport::Notifications.subscribe("libkey_search.spectrum_search_engine_primo") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.payload[:duration], labels: {
      source: event.payload[:source_id],
      query_word_count: event.payload[:params].keyword_count,
      query_has_booleans: event.payload[:params].has_booleans?,
      query_has_quoted_phrases: event.payload[:params].has_quotes?,
      response_total_items_magnitude: event.payload[:response].total_items_magnitude
    })
  end
end

ActiveSupport::Notifications.subscribe("solr_search.spectrum_search_engine_solr") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.payload[:duration], labels: {
      source: event.payload[:source_id],
      query_word_count: event.payload[:params].keyword_count,
      query_has_booleans: event.payload[:params].has_booleans?,
      query_has_quoted_phrases: event.payload[:params].has_quotes?,
      response_total_items_magnitude: event.payload[:response].total_items_magnitude
    })
  end
end

ActiveSupport::Notifications.subscribe("search_results_holdings_retrieval.spectrum_json_search") do |event|
  query_request_records = "n/a"
  query_word_count = "n/a"
  query_has_booleans = "n/a"
  query_has_quotes = "n/a"
  response_total_items_magnitude = "n/a"
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {
      source: "alma-search-holdings",
      query_word_count: query_word_count,
      query_has_booleans: query_has_booleans,
      query_has_quoted_phrases: query_has_quotes,
      response_total_items_magnitude: response_total_items_magnitude
    })
  end
end

ActiveSupport::Notifications.subscribe("single_record_holdings_retrieval.spectrum_json_search") do |event|
  query_request_records = "n/a"
  query_word_count = "n/a"
  query_has_booleans = "n/a"
  query_has_quotes = "n/a"
  response_total_items_magnitude = "n/a"
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {
      source: "alma-single-holdings",
      query_word_count: query_word_count,
      query_has_booleans: query_has_booleans,
      query_has_quoted_phrases: query_has_quotes,
      response_total_items_magnitude: response_total_items_magnitude
    })
  end
end

ActiveSupport::Notifications.subscribe("email.spectrum_json_act") do |event|
#  query_request_records = "n/a"
#  query_word_count = "n/a"
#  query_has_booleans = "n/a"
#  query_has_quotes = "n/a"
#  response_total_items_magnitude = "n/a"
#  Metrics(:api_response_duration_seconds) do |metric|
#    metric.observe(event.duration / 1000, labels: {
#      source: "email-load",
#      query_word_count: query_word_count,
#      query_has_booleans: query_has_booleans,
#      query_has_quoted_phrases: query_has_quotes,
#      response_total_items_magnitude: response_total_items_magnitude
#    })
#  end
end

ActiveSupport::Notifications.subscribe("file.spectrum_json_act") do |event|
#  query_request_records = "n/a"
#  query_word_count = "n/a"
#  query_has_booleans = "n/a"
#  query_has_quotes = "n/a"
#  response_total_items_magnitude = "n/a"
#  Metrics(:api_response_duration_seconds) do |metric|
#    metric.observe(event.duration / 1000, labels: {
#      source: "file-load",
#      query_word_count: query_word_count,
#      query_has_booleans: query_has_booleans,
#      query_has_quoted_phrases: query_has_quotes,
#      response_total_items_magnitude: response_total_items_magnitude
#    })
#  end
end

ActiveSupport::Notifications.subscribe("text.spectrum_json_act") do |event|
#  query_request_records = "n/a"
#  query_word_count = "n/a"
#  query_has_booleans = "n/a"
#  query_has_quotes = "n/a"
#  response_total_items_magnitude = "n/a"
#  Metrics(:api_response_duration_seconds) do |metric|
#    metric.observe(event.duration / 1000, labels: {
#      source: "text-load",
#      query_word_count: query_word_count,
#      query_has_booleans: query_has_booleans,
#      query_has_quoted_phrases: query_has_quotes,
#      response_total_items_magnitude: response_total_items_magnitude
#    })
#  end
end

ActiveSupport::Notifications.subscribe("fetch_records.spectrum_specialists") do |event|
#  Metrics(:api_response_duration_seconds) do |metric|
#    metric.observe(event.payload[:duration], labels: {
#      source: "catalog-solr-specialists",
#      query_word_count: "n/a",
#      query_has_booleans: "n/a",
#      query_has_quoted_phrases: "n/a",
#      response_total_items_magnitude: "n/a"
#    })
#  end
end

ActiveSupport::Notifications.subscribe("fetch_specialists_2step.spectrum_specialists") do |event|
#  Metrics(:api_response_duration_seconds) do |metric|
#    metric.observe(event.payload[:duration], labels: {
#      source: "website-solr-specialists-2nd-step",
#      query_word_count: "n/a",
#      query_has_booleans: "n/a",
#      query_has_quoted_phrases: "n/a",
#      response_total_items_magnitude: "n/a"
#    })
#  end
end

ActiveSupport::Notifications.subscribe("fetch_specialists_1step.spectrum_specialists") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.payload[:duration], labels: {
      source: "website-solr-specialists-1step",
      query_word_count: "n/a",
      query_has_booleans: "n/a",
      query_has_quoted_phrases: "n/a",
      response_total_items_magnitude: "n/a"
    })
  end
end

ActiveSupport::Notifications.subscribe("request.redirect_middleware") do |event|
  begin
    index = 0
    ObjectSpace.each_object(Puma::Cluster::Worker) { |w| index = w.index }
    fds = Dir.glob("/proc/#{Process.pid}/fd/*").length
    Metrics(:open_file_descriptors_total) do |metric|
      metric.set(fds, labels: { index: index })
    end

    cgroup = File.read("/proc/self/cgroup")
    # This default might work outside kubernetes
    path = "/sys/fs/cgroup" + cgroup.each_line.first.chomp.split(":")[2] + "cpu.stat"
    cgroup.each_line do |line|
      if line.include?("cpu,cpuacct")
        # This might work in kubernetes
        path = "/sys/fs/cgroup/cpu/cpuacct.usage"
      end
    end
    if File.exist?(path)
      cpu = nil
      if path.end_with?(".usage")
        cpu = (File.read(path).lines.first.chomp.to_i / 1000).to_i
      elsif path.end_with?(".stat")
        # I think this one is microseconds
        cpu = File.read(path).lines.first.chomp.split(' ').last.to_i
      end
      if cpu
        Metrics(:application_cpu_usage_usec) do |metric|
          metric.set(cpu)
        end
      end
    end
  rescue
  end
end
