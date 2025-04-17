class Money::Splitter
  def self.split(money, weights)
    new(money, weights).split
  end
  
  def initialize(money, weights)
    @money    = money
    @cents    = money.cents
    @currency = money.currency
    @weights  = normalize_weights(weights)
  end
  
  def split
    distribute_remainder(initial_shares).map(&method(:to_money))
  end
  
  private
  
  def to_money(cents)
    Money.from_subunit(cents, @currency)
  end

  def initial_shares
    cents_per_weight = @cents / @weights.sum.to_f    
    @weights.map { |weight| (weight * cents_per_weight).floor }
  end

  def distribute_remainder(shares)
    remainder = @cents - shares.sum
    remainder.times { |i| shares[i] += 1 }
    shares
  end
  
  def normalize_weights(weights)
    case weights
    when Array
      raise ArgumentError, "Weights must be an array of positive numbers" unless weights.all?(&:positive?)
      weights
    when Integer
      raise ArgumentError, "Number of parts must be at least 1" if weights < 1
      raise ArgumentError, "Cannot split #{@cents} cents into #{weights} parts" if weights > @cents.abs
      Array.new(weights, 1)
    else
      raise ArgumentError, "Weights must be a positive number or an array of positive numbers"
    end
  end
end