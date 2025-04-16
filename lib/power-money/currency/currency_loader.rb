require "set"
require "json"

class Currency::Loader
  DATA_PATH = File.expand_path("../../../../data", __FILE__)
  
  def self.call(path = DATA_PATH)
    new(path).load_currencies
  end
  
  def initialize(path = DATA_PATH)
    @load_path  = path
    @currencies = Set.new
  end
  
  def load_currencies
    @currencies.tap do |set|
      set.merge parse_file("currencies_iso.json")
      set.merge parse_file("currencies_non_iso.json")
      set.merge parse_file("currencies_backwards_compatible.json")
    end
  end
  
  private
  
  def parse_file(filename)
    path = File.join(@load_path, filename)
    file = File.read(path)
    data = JSON.parse(file) #, object_class: Currency)
    data.values.map { |attrs| Currency.new(**attrs) }.to_set
  end
end
