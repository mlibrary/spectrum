# frozen_string_literal: true

require "rails"

module Spectrum
  module Json
    class Railtie < Rails::Railtie
      initializer "spectrum-json.initialize" do
        Spectrum::Json.configure(Rails.root, Rails.configuration.relative_url_root)

        if File.exist?(location_labels_file = File.join(Rails.root, "config", "location_labels.yml"))
          Spectrum::Entities::LocationLabels.configure(location_labels_file)
        end
        if File.exist?(labels_file = File.join(Rails.root, "config", "alma_workflow_status_labels.json"))
          Spectrum::Entities::AlmaWorkflowStatusLabels.configure(labels_file)
        end

        if File.exist?(get_this_file = File.join(Rails.root, "config", "get_this.yml"))
          Spectrum::Entities::GetThisOptions.configure(get_this_file)
        end

        if File.exist?(specialists_file = File.join(Rails.root, "config", "specialists.yml"))
          Spectrum::Response::Specialists.configure(specialists_file)
        end
      end

      rake_tasks do
        load "spectrum/json.rake"
      end
    end
  end
end
