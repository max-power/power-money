require 'bigdecimal'
require 'net/http'
require 'nokogiri'
require 'time'

require_relative 'forex/memory_store'
require_relative 'forex/ecb_provider'
# Cache store can be:
# 1. PStore.new('cache.pstore')
# 2. YAML::Store.new('cache.yaml')
# 3. MemoryStore.new  

class Forex
  attr_accessor :provider, :store, :rates, :last_updated, :expires_in
  
  def initialize(provider: ECBProvider.new, store: MemoryStore.new, expires_in: 24*60*60)
    @provider = provider
    @store = store
    @expires_in = expires_in
    @last_updated = nil
    @rates = {}

    load_cache ? refresh_rates_if_needed : load_rates
  end

  def exchange(amount, from_currency, to_currency)
    refresh_rates_if_needed
    amount * rate(from_currency, to_currency)
  end
  
  def exchange_money(money, to_currency)
    amount = exchange(money.amount, money.currency_code, to_currency)
    Money.new(amount: amount, currency: to_currency)
  end
  
  def available_currencies
    @rates.keys
  end

  private

  def rate(from_currency, to_currency)
    rate_for(to_currency) / rate_for(from_currency)
  end

  def rate_for(currency)
    @rates.fetch(currency) do
      raise ArgumentError, "Currency #{currency} not supported"
    end
  end
  
  def cache_fresh?
    return false unless last_updated
    (Time.now - last_updated) < expires_in
  end

  def refresh_rates_if_needed
    load_rates unless cache_fresh?
  rescue => e
    if rates.any?
      warn "Warning: Failed to refresh rates: #{e.message}. Using cached rates."
    else
      raise "Error: No cached rates available and failed to load remote rates: #{e.message}"
    end
  end
  
  def load_rates
    @rates = provider.fetch_rates
    @last_updated = Time.now
    save_cache
  end
  
  def load_cache
    store.transaction(true) do
      cached_time  = store[:time]
      cached_rates = store[:rates]

      if cached_time && cached_rates
        @rates = cached_rates.transform_values { |rate| BigDecimal(rate.to_s) }
        @last_updated = Time.parse(cached_time)
        return true
      end
    end
    false
  rescue => e
    warn "Warning: Failed to load cache: #{e.message}"
    false
  end

  def save_cache
    store.transaction do
      store[:time]  = Time.now.utc.iso8601
      store[:rates] = @rates.transform_values(&:to_s)
    end
  end
end
