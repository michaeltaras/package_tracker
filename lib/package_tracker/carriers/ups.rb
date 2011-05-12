module PackageTracker
  class UPS < Carrier
    TEST_URL = "wwwcie.ups.com"
    LIVE_URL = "www.ups.com"
    PATH = "/ups.app/xml/Track"
    
    KEY = "7C7C172CCF7747B8"
    
    def initialize(attributes)
      @key = attributes[:key]
      @user_id = attributes[:user_id]
      @password = attributes[:password]
    end
  
    def track(tracking_number)
      repsonse = Request.post(request_url, PATH, request_data(tracking_number))
      puts repsonse
      response.body
    end
    
    
    private
    
    def request_url
      TEST_URL
    end
  
    def request_data(tracking_number)
      "<?xml version=\"1.0\"?>  
              <AccessRequest xml:lang='en-US'>  
                      <AccessLicenseNumber>#{@key}</AccessLicenseNumber>
                      <UserId>#{@user_id}</UserId>  
                      <Password>#{@password}</Password>  
              </AccessRequest>  
              <?xml version=\"1.0\"?>
              <TrackRequest>
                      <Request>
                              <TransactionReference>  
                                      <CustomerContext>  
                                              <InternalKey>blah</InternalKey>  
                                      </CustomerContext>  
                                      <XpciVersion>1.0</XpciVersion>  
                              </TransactionReference>  
                              <RequestAction>Track</RequestAction>  
                      </Request>  
              <TrackingNumber>#{tracking_number}</TrackingNumber>  
              </TrackRequest>"
    end
  end
end
