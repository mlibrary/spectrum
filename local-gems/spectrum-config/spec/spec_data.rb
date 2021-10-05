require 'marc'

module SpecData

  def self.path(name, context)
   File.expand_path(
      File.join('..', 'data', File.basename(context, '_spec.rb'), name ),
      __FILE__
    )
  end

  def self.load_bin(name, context)
    Marshal.load(File.binread(path(name,context)))
  end

  def self.load_json(name, context)
    JSON.parse(IO.read(path(name, context)))
  end

  def self.load_marcxml(name, context)
    ::MARC::XMLReader.new(path(name, context))
  end
end
