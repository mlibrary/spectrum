class Spectrum::Entities::AlmaWorkflowStatusLabels
  class << self
    def configure(labels)
      @labels = JSON.parse(File.read(labels))
    end

    def value(code)
      @labels[code]
    end
  end
end
