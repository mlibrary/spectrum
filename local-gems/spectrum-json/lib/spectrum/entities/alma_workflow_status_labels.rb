class Spectrum::Entities::AlmaWorkflowStatusLabels
  class << self
    def configure(labels)
      @labels = JSON.load_file(labels)
    end

    def value(code)
      @labels[code]
    end
  end
end
