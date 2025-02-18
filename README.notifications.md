# ActiveSupport::Notifications

This commit is adding ActiveSupport::Notifications instrumentation.  I am describing that in the following table.


| Event                                                    | Purpose                                             | Payload                         |
|----------------------------------------------------------|-----------------------------------------------------|---------------------------------|
| `primo_search.spectrum_search_engine_primo`              | Timing for primo API requests                       | `:source_id`, `:params`, `:url` |
| `libkey_search.spectrum_search_engine_primo`             | Timing for libkey API requests                      | `:source_id`, `:params`, `:url` |
| `primo_results.spectrum_search_engine_primo`             | Data about primo search results                     | `:results`                      |
| `solr_search.spectrum_search_engine_solr`                | Timing for solr API requests                        | `:source_id`, `:params`         |
| `solr_results.spectrum_search_engine_solr`               | Data about solr search results a                    | `:results`                      |
| `search_results_holdings_retrieval.spectrum_json_search` | Timing for retrieving holdings for search results   | `:full_response`                |
| `single_record_holdings_retrieval.spectrum_json_search`  | Timing for retireiving holdings for a single record | `:spectrum_response`            |
| `email.spectrum_json_act`                                | Timing for Email actions, retrieving records        | `:data`, `:username`, `:role`   |
| `file.spectrum_json_act`                                 | Timing for RIS actions, retrieving records          | `:data`, `:username`, `:role`   |
| `text.spectrum_json_act`                                 | Timing for Text actions, retireiving records        | `:data`, `:username`, `:role`   |
| `track.rack_attack`                                      | Data about http requests with cookies               | `:request`                      |
