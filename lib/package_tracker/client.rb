module PackageTracker
  class Client
    attr_accessor :credentials
    attr_reader :mode

    def initialize(credentials={})
      @credentials = credentials
    end

    def track(tracking_number, carrier=nil)
      # Fed Ex
      if carrier == :fedex || Carriers::FedEx.match(tracking_number)
        Carriers::FedEx.track(tracking_number, :credentials => @credentials[:fedex], :testing => testing?)
      # UPS
      elsif carrier == :ups || Carriers::UPS.match(tracking_number)
        Carriers::UPS.track(tracking_number, :credentials => @credentials[:ups], :testing => testing?)
      # USPS 
      elsif carrier == :usps || Carriers::USPS.match(tracking_number)
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