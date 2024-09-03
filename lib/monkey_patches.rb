class Object
  # lets you use  "a".in?(alphabet) instead of alphabet.include?("a")
  # pure syntactic sugar, but we're diabetics over here.
  def in?(*args)
    collection = (args.length == 1 ? args.first : args)
    collection ? collection.include?(self) : false
  end

  alias_method :one_of?, :in?

  def listify(opts = {})
    case self
    when NilClass
      opts[:include_nil] ? [nil] : []
    when Array
      self
    else
      [self]
    end
  end

  # returns a sorted list of methods that are unique to an object compared to some other object
  # compares to Object by default
  def interesting_methods(compare_to = Object)
    compare_to = compare_to.class unless compare_to.kind_of?(Class)
    (methods - compare_to.new.methods).sort
  end
end

class String
  # abbreviates strings to a fixed width, replacing the last few characters with padding
  # "this is very very long".abbreviate(15, "...") => "this is very..."
  # "this is short".abbreviate(15, "...") => "this is short"
  def abbreviate(characters, padding = '...')
    if length > characters
      self[0, characters - padding.length] + padding
    else
      self
    end
  end
end

class DateTime
  def to_solr_s
    to_s.gsub('+00:00', 'Z')
  end
end

# module Enumerable
#   # checks to see if any of the values in the enumerable are in
#   # [3,2,4].any_in?(6,1,2) => true
#   # [3,2,4].any_in?(5,6,7) => false
#   def any_in?(*args)
#     self.any? { |value| args.include?(value) }
#   end
# end

class Hash
  # creates a hash of arbitrary depth: you can refer to nested hashes without initialization.
  def self.arbitrary_depth
    Hash.new(&(p=lambda{|h, k| h[k] = Hash.new(&p)}))
  end

  # def recursive_symbolize_keys!
  #   symbolize_keys!
  #   values.select { |v| v.is_a? Hash }.each { |h| h.recursive_symbolize_keys! }
  #   self
  # end

  def deep_clone
    Marshal.load(Marshal.dump(self))
  end

  def recursive_merge(hash = nil)
    return self unless hash.is_a?(Hash)
    base = self
    hash.each do |key, v|
      if base[key].is_a?(Hash) && hash[key].is_a?(Hash)
        base[key].recursive_merge(hash[key])
      else
        base[key] = hash[key]
      end
    end
    base
  end
end

module ActionController::HttpAuthentication::Token
  AUTHN_PAIR_DELIMITERS = /(?:,|;|\t)/
end
