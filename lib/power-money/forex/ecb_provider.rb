class Forex
  class ECBProvider
    ECB_URL = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
  
    def fetch_rates
      ecb = Net::HTTP.get URI(ECB_URL)
      doc = Nokogiri::XML(ecb)

      rates = { "EUR" => BigDecimal("1.0") }
    
      doc.xpath('//xmlns:Cube[@currency]').each do |cube|
        rates[cube['currency']] = BigDecimal(cube['rate'])
      end

      rates
    rescue => e
      raise "Failed to load ECB rates: #{e.message}"
    end
  end
end
