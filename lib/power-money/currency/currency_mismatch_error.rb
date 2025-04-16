class CurrencyMismatchError < StandardError
  attr_reader :expected_currency, :actual_currency

  def initialize(expected_currency, actual_currency)
    @expected_currency = expected_currency
    @actual_currency = actual_currency
    super("Currency mismatch: expected #{expected_currency.iso_code}, got #{actual_currency.iso_code}")
  end
end
