require 'monitor'

class MemoryStore
  def initialize
    @data = {}
    @guard = Monitor.new
  end

  def transaction(read_only = false)
    @guard.synchronize do
      yield self
    end
  end

  def [](key)
    @data[key]
  end

  def []=(key, value)
    @data[key] = value
  end
end
