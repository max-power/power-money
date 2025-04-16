# frozen_string_literal: true

require "test_helper"

# ATTENTION: The space between amount and currency is a NARROW NO-BREAK SPACE!

class TestMoney < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Money::VERSION
  end
  
  ###########################################################################  
  # Initializable
  
  def test_initialization_with_bracket_syntax
    assert_equal Money.new(10, "DKK"), Money[10, "DKK"]
  end
  
  def test_initialization_with_currency_class_method
    assert_respond_to Money, :usd
    assert_respond_to Money, :thb
    assert_equal Money.new(10, "USD"), Money.usd(10)
    assert_equal Money.new(10, "EUR"), Money.eur(10)
  end
  
  def test_initialization_with_currency_class_method_weird
    assert_equal Money.new(10,   "USD"), Money::USD(10)
    assert_equal Money.new(9.99, "EUR"), Money::EUR(9.99)
  end
  
  def test_initialization_from_subunit
    assert_equal Money.new(10, "USD"), Money.from_subunit(1000, "USD")
  end
  
  def test_initialization_from_subunit_with_different_subunit_to_unit_ratios
    assert_equal Money.new(0.00000001, "BTC"), Money.from_subunit(1, "BTC")
    assert_equal Money.new(10, "VUV"), Money.from_subunit(10, "VUV")
    assert_kind_of BigDecimal, Money.from_subunit(10, "VUV").amount
  end
  
  def test_initialization_with_default_currency
    Money.default_currency = "THB"
    assert_equal "THB", Money.default_currency
    assert_equal Money.new(0,    "THB"), Money.zero
    assert_equal Money.new(1000, "THB"), Money.new(1000)
    assert_equal Money.new(1000, "THB"), Money[1000]
    assert_equal Money.new(1000, "THB"), Money.from_subunit(100000)
  ensure
    Money.default_currency = nil
  end
  
  def test_initialization_with_different_currency_class_types
    currency = Currency.find("DKK")
    assert_equal currency, Money.new(10, "DKK").currency
    assert_equal currency, Money.new(10, "dkk").currency
    assert_equal currency, Money.new(10, :DKK).currency
    assert_equal currency, Money.new(10, :dkk).currency
    assert_equal currency, Money.new(10, currency).currency
    assert_equal currency, Money.dkk(10).currency
  end
  
  ###########################################################################
  # Comparable
  
  def test_comparable
    assert_equal Money.new(10, "DKK"), Money.new(10, "DKK")
  end
  
  def test_comparision_with_zero_amount_and_different_currencies
    assert_equal Money.new(0, "USD"), Money.new(0, "USD")
    assert_equal Money.new(0, "USD"), Money.new(0, "EUR")
    assert_equal Money.new(0, "USD"), Money.new(0, "AUD")
    assert_equal Money.new(0, "USD"), Money.new(0, "JPY")
  end
  
  def test_comparision_with_diffenrent_currencies
    refute_equal Money.new(10, "USD"), Money.new(10, "EUR")
    refute_equal Money.new(10, "USD"), Money.new(10, "AUD")
  end
  
  def test_comparision_gt_lt
    assert Money.new(10, "EUR") < Money.new(20, "EUR")
    assert Money.new(10, "EUR") > Money.new(1, "EUR")
  end
  
  def test_comparable
    assert Money.new(10, "DKK").eql? Money.new(10, "DKK")
    refute Money.new(10, "DKK").eql? Money.new(10, "SEK")
  end
  
  def test_comparable_sort
    unsorted = [Money.eur(10), Money.eur(100), Money.eur(5), Money.eur(20)]
    sorted   = [Money.eur(5), Money.eur(10), Money.eur(20), Money.eur(100)]
    assert_equal sorted, unsorted.sort
  end
  
  
  ###########################################################################  
  # Cents
  
  def test_cents
    assert_equal 999, Money.new(9.99, "EUR").cents
    assert_equal 100, Money.new(100, "VUV").cents
  end
  
  def test_cents_method_missing
    assert_equal 100, Money.new(1, "CHF").rappen
    assert_equal 100, Money.new(1, "UZS").tiyin
    assert_equal 100000000, Money.new(1, "BTC").satoshi
  end

  
  ###########################################################################
  # Arithmetics
  
  def test_arithmetics_negative_positive
    assert Money.new(-9.99, "EUR").negative?
    refute Money.new(-9.99, "EUR").positive?
    assert Money.new(+9.99, "EUR").positive?
    refute Money.new(+9.99, "EUR").negative?
  end

  def test_arithmetics_zero
    assert Money.new(0,   "EUR").zero?
    refute Money.new(100, "EUR").zero?
  end
  
  def test_arithmetics_finite
    assert Money.new(100, "EUR").finite?
    refute Money.new(100, "EUR").infinite?
  end
  
  def test_arithmetics_minus_sign
    assert_equal Money.new(-10, "EUR"), -Money.new(10, "EUR")
    assert_equal Money.new(10, "EUR"), -Money.new(-10, "EUR")
  end
  
  def test_arithmetics_abs
    negative_money = Money.new(-10, "EUR") 
    assert negative_money.negative?
    assert_equal Money.new(10, "EUR"), negative_money.abs
  end
  
  def test_arithmetics_plus
    assert_equal Money.new(20, "EUR"),   Money.new(15, "EUR")  + Money.new(5, "EUR")
    assert_equal Money.new(20, "EUR"),   Money.new(-10, "EUR") + Money.new(30, "EUR")
    assert_equal Money.new(20, "EUR"),   Money.zero("EUR") + Money.eur(20)
  end
    
  def test_arithmetics_minus
    assert_equal Money.new( 20, "EUR"),  Money.new(50, "EUR") - Money.new(30, "EUR")
    assert_equal Money.new(-20, "EUR"),  Money.new(0, "EUR")  - Money.new(20, "EUR")
    assert_equal Money.new(-20, "EUR"),  Money.zero("EUR") - Money.eur(20)
  end
  
  def test_arithmetics_multi
    assert_equal Money.new( 20, "EUR"),  Money.new( 10, "EUR") * 2
    assert_equal Money.new(-30, "EUR"),  Money.new(-10, "EUR") * 3
    assert_equal Money.new(-30, "EUR"),  Money.new( 10, "EUR") * -3
    assert_equal Money.new(  0, "EUR"),  Money.new( 10, "EUR") * 0
    assert_equal Money.new(11.9,"EUR"),  Money.new( 10, "EUR") * 1.19
    assert_equal Money.new(  0, "EUR"),  Money.new(  0, "EUR") * 10
  end
  
  def test_arithmetics_div
    assert_equal Money.new( 10, "EUR"),  Money.new(20, "EUR")  / 2
    assert_equal Money.new(-30, "EUR"),  Money.new(-90, "EUR") / 3
    assert_equal Money.new(-10, "EUR"),  Money.new(30, "EUR")  / -3
    assert_equal Money.new(  0, "EUR"),  Money.zero("EUR") / 10
    assert_equal Money.new( 10, "EUR"),  Money.new(11.9, "EUR") / 1.19
  end

  def test_arithmetics_raises_zero_division
    assert_raises ZeroDivisionError do
      Money.new(10, "EUR") / 0
    end
  end
  
  def test_arithmetics_coerce
    assert_equal Money.new( 20, "EUR"),  2 * Money.new( 10, "EUR")
    assert_equal Money.new(-30, "EUR"),  3 * Money.new(-10, "EUR")
    assert_equal Money.new(-30, "EUR"), -3 * Money.new( 10, "EUR")
  end
  
  def test_arithmetics_raises
    assert_raises ArgumentError do
      Money.zero("EUR") + 5
    end
    
    assert_raises CurrencyMismatchError do
      Money.new(10, "EUR") + Money.new(10, "USD")
    end
  end
  
  ###########################################################################
  # Formatting
  
  def test_format
    assert_equal "€ 10,00",          Money.new(10, "EUR").format
    assert_equal "12 345 678,90 zł", Money.new(12345678.90, "PLN").format
    assert_equal "₹ 12,345,678.90",  Money.new(12345678.90, "INR").format
    assert_equal "₹ 1,23,45,678.90", Money.new(12345678.90, "INR").format(delimiter_style: :south_asia)
    assert_equal "₹ 1-23-45-678.90", Money.new(12345678.90, "INR").format(delimiter_style: :south_asia, delimiter: '-')
    assert_equal "₹ 1,23,45,678-90", Money.new(12345678.90, "INR").format(delimiter_style: :south_asia, seperator: '-')
  end
  
  def test_format_symbols
    assert_equal "10,00 zł",  Money.new(10, "PLN").format(symbol: true)
    assert_equal "10,00",     Money.new(10, "PLN").format(symbol: false)
    assert_equal "10,00",     Money.new(10, "PLN").format(symbol: nil)
    assert_equal "10,00",     Money.new(10, "PLN").format(symbol: "")
    assert_equal "10,00 PLN", Money.new(10, "PLN").format(symbol: :iso_code)
    assert_equal "10,00 Polish Złoty", Money.new(10, "PLN").format(symbol: :name)
    assert_equal "10,00 Schlotty",     Money.new(10, "PLN").format(symbol: "Schlotty")
  end
  
  def test_format_symbol_disambiguate
    assert_equal "$ 10.00",   Money.new(10, "SGD").format
    assert_equal "S$ 10.00",  Money.new(10, "SGD").format(symbol: :disambiguate)
  end
  
  def test_format_symbol_html
    assert_equal "10.00 ر.ق",       Money.new(10, "QAR").format
    assert_equal "10.00 &#xFDFC;",  Money.new(10, "QAR").format(symbol: :html)
  end
  
  def test_format_custom_format
    assert_equal "<span>$</span><b>10.00</b>", Money.new(10, "SGD").format(format: "<span>%u</span><b>%n</b>")
    assert_equal "10.00", Money.new(10, "SGD").format(format: "%n")
    assert_equal "Currency(SGD)", Money.new(10, "SGD").format(format: "Currency(%u)", symbol: :iso_code)
  end
  
  def test_form_custom_delimiter_pattern
    assert_equal "€ 1_0_0,00", Money.new(100, "EUR").format(delimiter_pattern: /(\d)(?=(\d)+(?!\d))/, delimiter: "_")
  end
  
  ###########################################################################
  # Splitting
  
  def test_splitting_equal
    assert_equal Array.new(2, Money.eur(50)),     Money.eur(100).split(2)
    assert_equal Array.new(4, Money.eur(-25.25)), Money.eur(-101).split(4)
  end
  
  def test_splitting_weighted
    assert_equal [Money.eur(50),    Money.eur(25),    Money.eur(25)],    Money.eur(100).split([2,1,1])
    assert_equal [Money.eur(33.5),  Money.eur(33.5),  Money.eur(33.5)],  Money.eur(100.5).split([0.33,0.33,0.33])
    assert_equal [Money.eur(33.34), Money.eur(33.33), Money.eur(33.33)], Money.eur(100).split([0.33,0.33,0.33])
  end
  
  
  ###########################################################################
  # Exchanging
  
  def test_exchanging
    money = Money.new(100, "EUR")
    assert_equal money, money.exchange_to("EUR")
    assert_equal "USD", money.exchange_to("USD").currency_code
    refute_equal money, money.exchange_to("USD")
  end
  
  def test_exchanging_aliases
    money = Money.new(100, "EUR")
    assert_respond_to money, :exchange_to
    assert_respond_to money, :to
    assert_respond_to money, :in
  end
end