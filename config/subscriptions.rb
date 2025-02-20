ActiveSupport::Notifications.subscribe("track.rack_attack") do |event|
  next unless event.payload[:request].env["rack.attack.matched"] == "haz_cookie"
  Metrics(:cookie_size_bytes) do |metric|
    metric.observe(event.payload[:request].env["HTTP_COOKIE"].bytesize)
  end
end

ActiveSupport::Notifications.subscribe("cookie_purge.spectrum_json") do |event|
  Metrics(:cookie_purge) do |metric|
    metric.increment
  end
end

ActiveSupport::Notifications.subscribe("primo_search.spectrum_search_engine_primo") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: event.payload[:source_id]})
  end
end

ActiveSupport::Notifications.subscribe("libkey_search.spectrum_search_engine_primo") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: event.payload[:source_id]})
  end
end

ActiveSupport::Notifications.subscribe("solr_search.spectrum_search_engine_solr") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: event.payload[:source_id]})
  end
end

ActiveSupport::Notifications.subscribe("search_results_holdings_retrieval.spectrum_json_search") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: "alma-search-holdings"})
  end
end

ActiveSupport::Notifications.subscribe("single_record_holdings_retrieval.spectrum_json_search") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: "alma-single-holdings"})
  end
end

ActiveSupport::Notifications.subscribe("email.spectrum_json_act") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: "email-load"})
  end
end

ActiveSupport::Notifications.subscribe("file.spectrum_json_act") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: "file-load"})
  end
end

ActiveSupport::Notifications.subscribe("text.spectrum_json_act") do |event|
  Metrics(:api_response_duration_seconds) do |metric|
    metric.observe(event.duration / 1000, labels: {source: "text-load"})
  end
end

#ActiveSupport::Notifications.subscribe("solr_results.spectrum_search_engine_solr") do |event|
#end

ActiveSupport::Notifications.subscribe("primo_results.spectrum_search_engine_primo") do |event|
  # TODO: Add logging for primo search results
  event.payload[:results].docs.each do |doc|
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
