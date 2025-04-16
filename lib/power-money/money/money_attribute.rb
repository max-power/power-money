# Example usage:
#
# class Product < ApplicationRecord
#   extend MoneyAttribute
#
#   money_attribute :price
# end
#
# class ProductPoro
#   extend MoneyAttribute
#   money_attribute :price
#   attr_accessor :price_amount, :price_currency
#
#   def initialize(price: nil)
#     self.price = price
#   end
# end
#
# p = Product.new(price: Money.thb(1234.56))
#
# Migration Reminder:
#
# add_column :products, :price_amount, :decimal, precision: 10, scale: 2
# add_column :products, :price_currency, :string
# 
# Validations:
#
# validates :price_amount, numericality: { greater_than: 0 }
# validates :price_currency, presence: true

module MoneyAttribute
  def money_attribute(attr_name)
    money_attribute_reader(attr_name)
    money_attribute_writer(attr_name)
  end
  
  private
  
  def money_attribute_reader(attr_name)
    define_method(attr_name) do
      amount   = send("#{attr_name}_amount")
      currency = send("#{attr_name}_currency")
      Money.new(amount, currency) unless amount.nil? || currency.nil?
    end
  end
  
  def money_attribute_writer(attr_name)
    define_method("#{attr_name}=") do |value|
      case value
      when Money
        send("#{attr_name}_amount=",   value.amount)
        send("#{attr_name}_currency=", value.currency_code)
      when Hash
        send("#{attr_name}_amount=",   value[:amount]   || value['amount'])
        send("#{attr_name}_currency=", value[:currency] || value['currency'])
      when String
        amount, currency_code = value.split
        send("#{attr_name}_amount=",   amount)
        send("#{attr_name}_currency=", currency_code)
      end
    end
  end
end

