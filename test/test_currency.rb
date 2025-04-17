# frozen_string_literal: true

require "test_helper"

class TestCurrency < TLDR
  def test_load_all_currencies
    assert_equal 194, Currency.all.count
  end
  
  def test_find_by_iso_code
    assert_equal "EUR", Currency.find("EUR").iso_code
  end
  
  def test_find_by_iso_numberic
    assert_equal "ALL", Currency.find_by_iso_numeric(8).iso_code
    assert_equal "ALL", Currency.find_by_iso_numeric("008").iso_code
    assert_equal "ALL", Currency.find_by_iso_numeric("08").iso_code
  end
  
  def test_exists
    assert Currency.exists?("EUR")
    assert Currency.exists?(:EUR)
    assert Currency.exists?("eur")
    refute Currency.exists?("XXX")
  end
  
  def test_wrap
    sek = Currency.find("SEK")
    assert_equal sek, Currency.wrap("SEK")
    assert_equal sek, Currency.wrap(:sek)
    assert_equal sek, Currency.wrap(sek)
    assert_nil Currency.wrap("XXX")
  end
  
  def test_find_by
    sek = Currency.find("SEK")
    assert_equal sek, Currency.find_by(name: "Swedish Krona")
    assert_equal sek, Currency.find_by(symbol: "kr", subunit: "Öre")
  end
  
  def test_generic_symbol
    assert_equal "¤", Currency::GENERIC_SYMBOL
  end
  
  def test_symbol
    assert_equal "€", Currency.find("EUR").symbol
    assert_equal "¤", Currency.new(iso_code: "ETH").symbol
    assert_equal "X", Currency.new(iso_code: "ETH", symbol: "X").symbol
  end
  
  def test_to_s
    assert_equal "BAM", Currency.find("BAM").to_s
  end
end