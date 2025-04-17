# require_relative "money/initializable"
# require_relative "money/rounding"
# require_relative "money/artithmetic"
# require_relative "money/splitting"
# require_relative "money/exchanging"
# require_relative "money/formatting"
# require_relative "money/cents"

Money = Data.define(:amount, :currency) do

  module Initializable
    def zero(currency = Money.default_currency)
      new(0, currency)
    end
    
    def from_subunit(cents, currency = Money.default_currency)
      currency = Currency.wrap(currency)
      amount   = BigDecimal(cents) / currency.subunit_to_unit
      new(amount, currency)
    end
  
    def method_missing(method_name, *args, &block)
      if args.size == 1 && Currency.exists?(method_name)
        new(args.first, method_name)
      else
        super
      end
    end
  
    def respond_to_missing?(method_name, include_private = false)
      Currency.exists?(method_name) || super
    end
  end
  
  module Rounding
    def round(decimals = 0)
      rounded(:round, decimals)
    end

    def ceil(decimals = 0)
      rounded(:ceil, decimals)
    end

    def floor(decimals = 0)
      rounded(:floor, decimals)
    end

    def truncate(decimals = 0)
      rounded(:truncate, decimals)
    end

    private

    def rounded(method, decimals)
      with amount: amount.public_send(method, decimals)
    end
  end
  
  module Arithmetic
    def +(other)
      ensure_same_currency!(other)
      with amount: amount + other.amount
    end
  
    def -(other)
      ensure_same_currency!(other)
      with amount: amount - other.amount
    end
  
    def *(scalar)
      ensure_numeric!(scalar, "Multiplier")
      with amount: amount * scalar
    end
  
    def /(scalar)
      ensure_numeric!(scalar, "Divisor")
      ensure_not_zero!(scalar)
      with amount: amount.to_f / scalar
    end
    
    def -@
      with amount: -amount
    end
  
    def +@
      with amount: +amount
    end
  
    def abs
      with amount: amount.abs
    end
    
    def coerce(other)
      raise TypeError, "Cannot coerce #{other.class} into Money" unless other.is_a?(Numeric)
      [self, other]
    end
    
    private
    
    def ensure_same_currency!(other)
      raise ArgumentError unless other.is_a?(Money)
      raise CurrencyMismatchError.new(currency, other.currency) unless currency == other.currency
    end
    
    def ensure_numeric!(scalar, part)
      raise ArgumentError, "#{part} must be numeric" unless scalar.is_a?(Numeric)
    end
    
    def ensure_not_zero!(scalar)
      raise ZeroDivisionError, "Division by zero" if scalar.zero?
    end
  end
  
  module Splitting
    def split(parts, splitter: Money::Splitter)
      splitter.split(self, parts)
    end
  end
  
  module Exchanging
    def exchange_to(other_currency, forex: Forex.new)
      other_currency = Currency.wrap(other_currency)
      return self if currency == other_currency
           
      forex.exchange_money(self, other_currency.iso_code)
    end
    alias_method :in, :exchange_to
    alias_method :to, :exchange_to
  end
  
  module Formatting
    TEMPLATE_PATH  = File.expand_path('../../../templates/money.html.erb', __FILE__)

    def format(**options)
      Money::Formatter.new(self, **options).call
    end
    
    def to_s
      format(symbol: false, delimiter: "", seperator: ".")
    end
    
    def to_html
      ERB.new(File.read(TEMPLATE_PATH), trim_mode: '-').result(binding)
    end
    
    def inspect
      "#<#{self.class.name} amount:#{to_f} currency:#{currency_code}>"
    end
  end
  
  module Cents
    def cents
      (amount * currency.subunit_to_unit).to_i
    end
  
    def method_missing(method_name, *args, &block)
      currency && method_name.to_s == currency.subunit.downcase ? cents : super
    end
  
    def respond_to_missing?(method_name, include_private = false)
      currency && method_name.to_s == currency.subunit.downcase || super
    end
  end
  
  module Config
    attr_accessor :default_currency
  end
  
  extend  Forwardable, Initializable, Config
  include Comparable, Cents, Arithmetic, Rounding, Formatting, Exchanging, Splitting
  
  def_delegators :amount, :to_i, :to_f, :to_r, :to_c, :fix, :frac, :sign
  def_delegators :amount, :zero?, :nonzero?, :positive?, :negative?, :finite?, :infinite?
  
  def initialize(amount:, currency: Money.default_currency)
    currency = Currency.wrap(currency)
    amount   = BigDecimal(amount.to_s).round(currency.precision, BigDecimal::ROUND_HALF_UP)
    super(amount: amount, currency: currency)
  end
  
  def currency_symbol
    currency.symbol
  end
  
  def currency_code
    currency.iso_code
  end
  
  def ==(other)
    (other.is_a?(Money) && zero? && other.zero?) ? true : super
  end
  alias :eql? :==
  
  def <=>(other)
    return nil unless other.is_a?(Money)
    return 0 if zero? && other.zero?
    return nil unless currency == other.currency
    amount <=> other.amount
  end
end
