namespace "locations" do
  namespace "clean" do
    desc "Clean instLoc.yaml"
    task "institutions" do
      data = YAML.load_file("config/instLoc.yaml")
      puts data.to_yaml
    end
    desc "Clean locColl.yaml"
    task "collections" do
      data = YAML.load_file("config/locColl.yaml")
      puts data.to_yaml
    end
  end
  namespace "generate" do
    desc "Generate instLoc.yaml"
    task "institutions-map" do
    end

    desc "Generate location facets"
    task "facet-data" do

      possible_keys = []
      client = AlmaRestClient.client
      libraries_response = client.get("/conf/libraries")
      if libraries_response.code == 200
        libraries_response.parsed_response["library"].each do |library|
          library_code = library["code"]
          possible_keys << library_code
          collections_path = library["number_of_locations"]["link"][49..]
          collections_response = client.get(collections_path)
          if collections_response.code == 200
            collections_response.parsed_response["location"].each do |collection|
              collection_code = collection["code"]
              possible_keys << collection_code
              possible_keys << "#{library_code} #{collection_code}"
            end
          end
        end
      end
       
      loc_coll_data = YAML.load_file("config/locColl.yaml")
      possible_keys = (possible_keys +
        loc_coll_data.keys +
        loc_coll_data.values.map { |value| value["collections"].keys }.flatten +
        YAML.load_file("config/instLocs.yaml").values.map {|value| value["sublibs"]}
      ).flatten.uniq
      
      solr = RSolr.connect(url: ENV["SPECTRUM_CATALOG_SOLR_URL"])
      results = solr.get('select', params: {q: "*:*", rows: 0, "facet.field" => "location", "facet.limit" => -1, facet: "on"})
      facets = results.dig("facet_counts", "facet_fields", "location")&.each_slice(2)&.reject do |facet|
        !possible_keys.include?(facet[0])
      end&.to_h
      print facets.to_yaml
    end

    desc "Generate locColl.yml"
    task "collections-map" do

      data = {
        "ALL" => {
          "desc" => "All locations",
          "collections" => { "ALL" => "All collections" }
        }
      }
      client = AlmaRestClient.client
      libraries_response = client.get("/conf/libraries")

      skip_libraries = []
      skip_collections = ["NONE"]
      if libraries_response.code == 200

        libraries_response.parsed_response["library"].each do |library|
          library_code = library["code"]
          library_name = library["name"]
          next if skip_libraries.include?(library_code)
          collections_path = library["number_of_locations"]["link"][49..]
          collections_response = client.get(collections_path)
          if collections_response.code == 200
            data[library_code] = {
              "desc" => library_name,
              "collections" => {
                "ALL" => "All collections"
              }
            }
            collections_response.parsed_response["location"].each do |collection|
              collection_code = collection["code"]
              collection_name = collection["external_name"]
              combined_code = "#{library_code} #{collection_code}"
              next if skip_collections.include?(collection_name)
              next if collection_name.match?(%r(^\d$))
              data[library_code]["collections"][combined_code] = collection_name
            end
          end
        end
      end
      print data.to_yaml
    end
  end
end
