# frozen_string_literal: true

require "json-schema"
require "lru_redux"
require "alma_rest_client"
require "mlibrary_search_parser"
require "mlibrary_search_parser/transformer/solr/sometimes_quoted_local_params"

require "active_support"
require "active_support/concern"

require "sinatra"
require "sinatra/json"

require "spectrum/available_online_holding"
require "spectrum/empty_item_holding"
require "spectrum/bib_record"
require "spectrum/special_collections_bib_record"

require "spectrum/alma_client"

require "spectrum/entities/entities"
require "spectrum/entities/alma_holdings"
require "spectrum/entities/alma_item"
require "spectrum/entities/hathi_holding"
require "spectrum/entities/combined_holdings"
require "spectrum/entities/alma_user"
require "spectrum/entities/alma_hold"
require "spectrum/entities/get_this_work_order_option"
require "spectrum/entities/get_this_options"
require "spectrum/entities/get_this_option"
require "spectrum/entities/location_labels"
require "spectrum/entities/alma_workflow_status_labels"

require "spectrum/decorators/physical_item_decorator"

require "spectrum/json/version"
require "spectrum/json/schema"

require "spectrum/json/monkey_patches"

require "spectrum/json/ris"
require "spectrum/json/twilio"
require "spectrum/json/email"
require "spectrum/json/favorites"

require "spectrum/response"
require "spectrum/response/spectrumable"
require "spectrum/response/raw_json"
require "spectrum/response/message"
require "spectrum/response/data_store"
require "spectrum/response/data_store_list"
require "spectrum/response/facet_list"
require "spectrum/response/record"
require "spectrum/response/record_list"
require "spectrum/response/holdings"
require "spectrum/response/null_holdings"
require "spectrum/response/get_this"
require "spectrum/response/place_hold"
require "spectrum/response/specialists"
require "spectrum/response/action"
require "spectrum/response/text"
require "spectrum/response/email"
require "spectrum/response/file"
require "spectrum/response/favorite"
require "spectrum/response/unfavorite"
require "spectrum/response/tag"
require "spectrum/response/untag"
require "spectrum/response/list_favorites"
require "spectrum/response/suggest_favorites"
require "spectrum/response/profile"
require "spectrum/response/debug"

require "spectrum/field_tree"
require "spectrum/field_tree/base"
require "spectrum/field_tree/field"
require "spectrum/field_tree/field_boolean"
require "spectrum/field_tree/literal"
require "spectrum/field_tree/empty"
require "spectrum/field_tree/invalid"
require "spectrum/field_tree/raw"

require "spectrum/facet_list"

require "spectrum/request"
require "spectrum/request/record"
require "spectrum/request/requesty"
require "spectrum/request/null"
require "spectrum/request/facet"
require "spectrum/request/data_store"
require "spectrum/request/holdings"
require "spectrum/request/get_this"
require "spectrum/request/place_hold"
require "spectrum/request/action"
require "spectrum/request/text"
require "spectrum/request/email"
require "spectrum/request/file"
require "spectrum/request/favorite"
require "spectrum/request/unfavorite"
require "spectrum/request/tag"
require "spectrum/request/untag"
require "spectrum/request/list_favorites"
require "spectrum/request/suggest_favorites"
require "spectrum/request/profile"
require "spectrum/request/debug"

require "spectrum/presenters"
require "spectrum/presenters/holding_presenter/base"
require "spectrum/presenters/holding_presenter/alma_holding_presenter"
require "spectrum/presenters/holding_presenter/electronic_holding_presenter"
require "spectrum/presenters/holding_presenter/hathi_holding_presenter"
require "spectrum/presenters/holding_presenter/empty_holding_presenter"
require "spectrum/presenters/holding_presenter"
require "spectrum/presenters/physical_item_presenter"
require "spectrum/presenters/electronic_item_presenter"
require "spectrum/holding/physical_item_status"
require "spectrum/holding/physical_item_status_text"
require "spectrum/holding/action"
require "spectrum/holding/no_action"
require "spectrum/holding/finding_aid_action"
require "spectrum/holding/get_this_action"
require "spectrum/holding/request_this_action"

require "erb"

module Spectrum
  module Json
    class << self
      attr_reader :base_url, :actions, :filter, :fields, :foci, :sorts, :sources, :bookplates

      def configure(root, base_url)
        @base_url = base_url
        @actions_file = File.join(root, "config", "actions.yml")
        @filters_file = File.join(root, "config", "filters.yml")
        @fields_file = File.join(root, "config", "fields.yml")
        @focus_files = File.join(root, "config", "foci", "*.yml")
        @sources_file = File.join(root, "config", "source.yml")
        @sorts_file = File.join(root, "config", "sorts.yml")
        @bookplates_file = File.join(root, "config", "bookplates.yml")
        Spectrum::Config::FacetParents.configure(root)

        if File.exist?(location_labels_file = File.join(root, "config", "location_labels.yml"))
          Spectrum::Entities::LocationLabels.configure(location_labels_file)
        end
        if File.exist?(labels_file = File.join(root, "config", "alma_workflow_status_labels.json"))
          Spectrum::Entities::AlmaWorkflowStatusLabels.configure(labels_file)
        end

        if File.exist?(get_this_file = File.join(root, "config", "get_this.yml"))
          Spectrum::Entities::GetThisOptions.configure(get_this_file)
        end

        if File.exist?(specialists_file = File.join(root, "config", "specialists.yml"))
          Spectrum::Response::Specialists.configure(specialists_file)
        end

        MARC::ControlField.control_tags.add("FMT")

        configure!
      end

      def configure!
        if File.exist?(@actions_file)
          @actions = Spectrum::Config::ActionList.new(YAML.safe_load(ERB.new(File.read(@actions_file)).result))
        end

        if File.exist?(@sources_file)
          @sources = Spectrum::Config::SourceList.new(YAML.safe_load(ERB.new(File.read(@sources_file)).result))
        end

        if File.exist?(@bookplates_file)
          @bookplates = Spectrum::Config::BookplateList.new(YAML.safe_load(ERB.new(File.read(@bookplates_file)).result))
        end

        if File.exist?(@filters_file)
          @filters = Spectrum::Config::FilterList.new(YAML.safe_load(ERB.new(File.read(@filters_file)).result))
        end

        if File.exist?(@sorts_file)
          @sorts = Spectrum::Config::SortList.new(YAML.safe_load(ERB.new(File.read(@sorts_file)).result))
        end

        if File.exist?(@fields_file)
          @fields = Spectrum::Config::FieldList.new(YAML.safe_load(ERB.new(File.read(@fields_file)).result), self)
        end

        if @sources && !(focus_files_list = Dir.glob(@focus_files)).empty?
          @foci = Spectrum::Config::FocusList.new(
            # aliases true for safe load
            focus_files_list.map { |file| YAML.safe_load(ERB.new(File.read(file)).result, aliases: true) },
            self
          )
        end

        @actions&.configure!

        if @sources && @foci
          request = Spectrum::Request::DataStore.new

          @foci.values.each do |focus|
            focus.get_null_facets do
              source = @sources[focus.source]
              engine = source.engine(focus, request, nil)
              begin
                results = engine.search
                focus.apply_facets!(results)
              rescue
                # TODO
              end
            end
          end
        end

        require "spectrum/json/app"

        self
      end

      def routes(app)
        foci.routes(app) if foci.respond_to?(:routes)
      end
    end
  end
end
