module PackageTracker
  class Client
    attr_accessor :credentials
    attr_reader :mode

    def initialize(credentials={})
      @credentials = credentials
    end

    def track(tracking_number, carrier=nil)
      # Fed Ex
      if carrier == :fedex || tracking_number =~ /^\w{9}$/ || tracking_number =~ /^\d{12,15}$/ || tracking_number =~ /^96\d{20}$/
        Carriers::FedEx.track(tracking_number, :credentials => @credentials[:fedex], :testing => testing?)
      # UPS
      elsif carrier == :ups || tracking_number =~ /^1Z\d*/
        Carriers::UPS.track(tracking_number, :credentials => @credentials[:ups], :testing => testing?)
      # USPS 
      elsif carrier == :usps || tracking_number =~ /^\d{20}$/ || tracking_number =~ /^\d{30}$/ || tracking_number =~ /^[A-Za-z]{2}\d{9}[A-Za-z]{2}$/
        throw CarrierNotFoundError, "Need to impliment USPS"
      # DHL
       else
        throw CarrierNotFoundError
      end
    end
        
    def testing?
      @mode == "testing"
    end
    
    def test_mode!
      @mode = "testing"
    end
    
    def production_mode!
      @mode == "production"
    end
  end
end