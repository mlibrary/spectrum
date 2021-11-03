class FieldStub
  attr_accessor :sub, :value
  def initialize(sub, value)
    self.sub = sub
    self.value = value
  end

  def find_all(&block)
    [ SubfieldStub.new(sub, value) ].find_all &block
  end
end

