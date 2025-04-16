# Money

A Ruby Library for dealing with money and currencies.

## Usage

```
require 'power-money'

# 10.00 EUR
money = Money.new(10, "EUR")
money.cents           # 1000
money.amount          # BigDecimal("10.00")
money.currency        # <Currency…>
money.currency_symbol # "€"
money.currency_code   # "EUR"

# 10.00 CHF
money = Money.new(10, "CHF")
money.cents    # 1000
money.rappen   # 1000 # the currency subunit is aliased to .cents
money.currency_code # "CHF"

# Initializing

Money.new(9.95, "EUR") # with string currency
Money.new(9.95, "eur") # case doesnt matter
Money.new(9.95, :EUR)  # with symbol currency
Money.new(9.95, :eur)
Money.new(9.95, Currency.find("EUR")) # with another currency

Money[9.95, "EUR"]

Money.eur(9.95)
Money::EUR(9.95)

Money.from_subunit(995, "EUR") # from cent amount

Money.zero("EUR")

# with default currency

Money.default_currency = "EUR"

Money.new(9.95)
Money.zero

# Formatting

Money.sgd(9.95).format # "$ 9,95"

Money.sgd(9.95).format(symbol: true)          # "$ 9,95"
Money.sgd(9.95).format(symbol: false)         # "9,95"
Money.sgd(9.95).format(symbol: nil)           # "9,95"
Money.sgd(9.95).format(symbol: "")            # "9,95"
Money.sgd(9.95).format(symbol: :iso_code)     # "EUR 9,95"
Money.sgd(9.95).format(symbol: :disambiguate) # "S$ 9.95"
Money.sgd(9.95).format(symbol: :name)         # "Singapore Dollar 9.95"
Money.sgd(9.95).format(symbol: "X$")          # "X$ 9.95"
Money.ang(9.95).format(symbol: :html).        # "&#x0192; 9,95"

Money.inr(123456789.95).format                                 # "₹ 123,456,789.95"
Money.inr(123456789.95).format(delimiter_style: :south_asia)   # "₹ 12,34,56,789.95"
Money.inr(123456789.95).format(delimiter: "-", seperator: "/") # "₹ 123-456-789/95"

Money.new(10, "SGD").format(format: "%n%u")   # "10.00$"
Money.new(10, "SGD").format(format: "%n")     # "10.00"
Money.new(10, "SGD").format(format: "<span>%u</span><b>%n</b>") # "<span>$</span><b>10.00</b>"

# Exchanging

Money.new(100, "EUR").exchange_to("USD")
Money.eur(100).to("USD") # exchange_to is aliased to .to(other) and .in(other)
Money::EUR(100).in(:USD)

# Comparing

Money.new(10, "EUR") == Money.new(10, "EUR") # true
Money.new(10, "EUR") == Money.new(10, "USD") # false
Money.new( 0, "EUR") == Money.new( 0, "USD") # true

Money.new( 0, "EUR") < Money.new(10, "EUR") # true
Money.new( 0, "EUR") > Money.new(10, "EUR") # false

[Money.eur(100), Money.eur(50), Money.eur(10)].sort # 10, 50, 100

````

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/max-power/power-money.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
