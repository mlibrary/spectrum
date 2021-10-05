# frozen_string_literal: true

module Spectrum
  module FieldTree
    class Base; end
    class ChildFreeBase < Base; end
    class FieldBoolean < Base; end
    class ValueBoolean < Base; end
    class Tag < Base; end
    class Field < Base; end
    class Special < ChildFreeBase; end
    class Literal < ChildFreeBase; end
    class Raw < ChildFreeBase; end
    class Invalid < RuntimeError; end
    class Empty; end

    def self.new(data = nil, types = Base::TYPES)
      if data.nil? || data.keys.empty?
        Empty.new
      elsif data['type']
        if types.key?(data['type'])
          types[data['type']].new(data)
        else
          Invalid.new("FieldTree: Invalid type (#{data['type']}).")
        end
      else
        Invalid.new('FieldTree: No type provided.')
      end
    end
  end
end
