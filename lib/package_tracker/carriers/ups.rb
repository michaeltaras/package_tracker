module PackageTracker
  module Carriers
    module UPS
      extend Carrier
      extend self
      
      TEST_URL = "wwwcie.ups.com"
      LIVE_URL = "www.ups.com"
      PATH = "/ups.app/xml/Track"
      
      def name
        "UPS"
      end

      def track(tracking_number, options)
        validate_credentials!(options[:credentials])
        repsonse = Request.post(request_url(options[:testing]), PATH, request_data(tracking_number, options[:credentials]))
        parse_response(tracking_number, repsonse)
      end
      
      def match(tracking_number)
        tracking_number =~ /^1Z\d*/
      end
    
      def delivered_status
        "DELIVERED"
      end
  
      private
      
      def request_url(testing)
        TEST_URL # apparently we don't need the live url for tracking
      end
  
      def required_credentials
        [:user_id, :key, :password]
      end
      
      def request_data(tracking_number, credentials)
        "<?xml version='1.0'?>
          <AccessRequest xml:lang='en-US'>
            <AccessLicenseNumber>#{credentials[:key]}</AccessLicenseNumber>
            <UserId>#{credentials[:user_id]}</UserId>
            <Password>#{credentials[:password]}</Password>
          </AccessRequest>
          <?xml version='1.0'?>
          <TrackRequest xml:lang='en-US'>
            <Request>
              <TransactionReference>
                <XpciVersion>1.0</XpciVersion>
              </TransactionReference>
              <RequestAction>Track</RequestAction>
              <RequestOption>activity</RequestOption>
            </Request>
            <TrackingNumber>#{tracking_number}</TrackingNumber>
          </TrackRequest>
        "
      end
  
      def parse_response(tracking_number, response)
        handle_errors(response)
        
        tracking_response = Response.new(tracking_number, self)
        Nokogiri::XML(response.body).css("Package Activity").each do |activity|
          location = ""
          location += "#{activity.css("City").text}, " unless activity.css("City").empty?
          location += "#{activity.css("StateProvinceCode").text}, " unless activity.css("StateProvinceCode").empty?
          location += "#{activity.css("CountryCode").text}"
          
          tracking_response.add_status(
            activity.css("Status Description").text,
            Time.parse(activity.css("Date").text + activity.css("Time").text),
            location
          )
        end
        tracking_response
      end
      
      def handle_errors(response)
        case Nokogiri::XML(response.body).css("Error ErrorCode").text
          when "250003" then raise InvalidCredentialsError
          when "151018" then raise InvalidTrackingNumberError
        end
      end
      
    end
  end
end
