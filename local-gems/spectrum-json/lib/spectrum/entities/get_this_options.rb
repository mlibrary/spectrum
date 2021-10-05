require 'yaml'
class Spectrum::Entities::GetThisOptions
  class << self
    def configure(options)
      @options = YAML.load_file(options)
    end
    def for(patron, bib, item)
      attributes = { 'patron' => patron, 'bib' => bib, 'holding' => item }
      selection = @options.select do |option|
        option['grants'].map do |attribute, features | 
          features.all? {|feature| attributes[attribute].send(feature)}
        end.all?
      end
      selection&.map do |x| 
        Spectrum::Entities::GetThisOption.for(option: x, patron: patron, item: item).to_h
      end
    end
    def all
      @options
    end
  end
end
