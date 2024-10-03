class Hash
  def deep_clone
    Marshal.load(Marshal.dump(self))
  end
end
