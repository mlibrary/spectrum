require 'yaml'
class Spectrum::Entities::LocationLabels
  class << self
    def configure(services)
      services = YAML.load_file(services)
      @get_this = services["get_this"]
    end
    def get_this(code)
      @get_this.find{|x| x["code"] == code}&.dig("text")
    end
  end
end

