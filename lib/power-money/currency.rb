class Currency < Struct.new(
    :iso_code,
    :iso_numeric,
    :name,
    :symbol,
    :alternate_symbols,
    :disambiguate_symbol,
    :subunit,
    :subunit_to_unit,
    :symbol_first,
    :format,
    :html_entity,
    :decimal_mark,
    :thousands_separator,
    :smallest_denomination,
    :priority,
  )
  
  module ClassMethods  
    def all
      @currencies ||= Currency::Loader.call
    end

    def find(code)
      find_by(iso_code: code.to_s.upcase)
    end
  
    def find_by_iso_numeric(num)
      find_by(iso_numeric: num.to_s.rjust(3, '0'))
    end
  
    def find_by(**criteria)
      all.find do |currency|
        criteria.all? do |key, value|
          currency.respond_to?(key) && currency.public_send(key) == value
        end
      end
    end
    
    def exists?(code)
      return false if code.size != 3
      !!find(code)
    end
    
    def wrap(object)
      case object
      when Currency
        object
      else
        find(object.to_s.upcase)
      end
    end
  end
  
  extend ClassMethods
  
  GENERIC_SYMBOL = "¤".freeze
  
  def symbol
    self[:symbol] || GENERIC_SYMBOL
  end
  
  def precision
    Math.log10(subunit_to_unit).round
  end
  alias_method :exponent, :precision
  
  def to_s
    iso_code
  end
  
  def to_json
    to_h.to_json
  end
end
