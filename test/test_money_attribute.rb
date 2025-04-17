# frozen_string_literal: true

require "test_helper"

class TestMoneyAttribute < TLDR
  
  class Product
    extend MoneyAttribute
    money_attribute :price
    attr_accessor :price_amount, :price_currency
  
    def initialize(price: nil)
      self.price = price
    end
  end

  def test_sets_amount_and_currency_from_money
    money   = Money.eur(1234.56)
    product = Product.new(price: money)
    
    assert_kind_of Money, product.price
    
    assert_equal BigDecimal("1234.56"), product.price_amount
    assert_equal "EUR", product.price_currency
  end
  
  def test_sets_amount_and_currency_from_hash
    product = Product.new(price: {amount: 10, currency: "USD"})
    
    assert_kind_of Money, product.price
    assert_equal Money.usd(10), product.price
  end
  
  def test_sets_amount_and_currency_from_string
    product = Product.new(price: "10 USD")
    
    assert_kind_of Money, product.price
    assert_equal Money.usd(10), product.price
  end
end