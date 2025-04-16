class Money::Formatter
  SPACE = "\u0020"
  NUMSP = "\u2007" # FIGURE SPACE: Produces a space equal to the figure (0–9) characters.
  NNBSP = "\u202F" # NARROW NO-BREAK SPACE: Recommended for usage in the SI-standard.
  ZNBSP = "\uFEFF" # ZERO WIDTH NO-BREAK SPACE

  DEFAULT_DELIMITER_PATTERN    = /(\d)(?=(\d\d\d)+(?!\d))/
  SOUTH_ASIA_DELIMITER_PATTERN = /(\d+?)(?=(\d\d)+(\d)(?!\d))/
  
  extend Forwardable
  
  def_delegators :@currency, :precision, :thousands_separator, :decimal_mark, 
                             :iso_code, :symbol, :disambiguate_symbol, 
                             :alternate_symbols, :html_entity, :symbol_first

  def initialize(money, **options)
    @amount   = money.amount
    @currency = money.currency
    @options  = options
  end
  
  def call
#    sprintf(template, n: amount_with_delimiter, u: currency_symbol)
    format.gsub(/\s/, space).gsub(/%[nu]/, "%n" => amount_with_delimiter, "%u" => currency_symbol)
  end
  
  private

  def amount_with_delimiter
    integer, decimal = amount_with_precision.split(".")
    integer.gsub!(delimiter_pattern, '\1' + delimiter) unless delimiter.empty?
    [integer, decimal].compact.join(seperator)
  end
  
  def amount_with_precision
    sprintf("%.#{precision}f", @amount)
  end
   
  def currency_symbol
    case @options.fetch(:symbol, true)
    when :disambiguate
      disambiguate_symbol || symbol
    when :html
      html_entity || symbol
    when :iso_code, :code
      iso_code
    when :name
      @currency.name
    when String
      @options[:symbol]
    when true
      symbol
    else
      ""
    end
  end
  
  def template
    format.gsub(/%([nu])/, '%{\1}').gsub(/\s/, space)
  end
  
  def format
    @options.fetch(:format) { @currency.format || default_format }
  end
  
  def default_format
    symbol_first ? "%u %n" : "%n %u"
  end
  
  def space
    return "" if currency_symbol.empty?
    @options.fetch(:space) { NNBSP }
  end
  
  def precision
    @options.fetch(:precision) { @currency.precision }
  end
  
  def seperator
    @options.fetch(:seperator) { decimal_mark }
  end
  
  def delimiter
    @options.fetch(:delimiter) { thousands_separator }
  end
  
  def delimiter_pattern
    @options.fetch(:delimiter_pattern) { delimiter_default_pattern }
  end
  
  def delimiter_default_pattern
    @options[:delimiter_style] == :south_asia ? SOUTH_ASIA_DELIMITER_PATTERN : DEFAULT_DELIMITER_PATTERN
  end
end
