module PackageTracker
  module Carriers
    module FedEx
      extend Carrier
      extend self
      
      TEST_URL = 'gatewaybeta.fedex.com'
      LIVE_URL = 'gateway.fedex.com'
    
      PATH = "/xml"
      PORT = "443"
        
      def track(tracking_number, options)
        validate_credentials!(options[:credentials])
        repsonse = Request.post(
          request_url(options[:testing]), 
          PATH, 
          request_data(tracking_number, options[:credentials]), 
          :https => true,
          :port => PORT
        )
        parse_response(tracking_number, repsonse)
      end

      private
    
      def required_credentials
        [:key, :password, :account, :meter]
      end
    
      def request_url(testing)
        testing ? TEST_URL : LIVE_URL
      end
    
      def request_data(tracking_number, credentials)
        "<?xml version='1.0'?>
         <TrackRequest xmlns='http://fedex.com/ws/track/v3'>
           <WebAuthenticationDetail>
             <UserCredential>
               <Key>#{credentials[:key]}</Key>
               <Password>#{credentials[:password]}</Password>
             </UserCredential>
           </WebAuthenticationDetail>
           <ClientDetail>
             <AccountNumber>#{credentials[:account]}</AccountNumber>
             <MeterNumber>#{credentials[:meter]}</MeterNumber>
           </ClientDetail>
           <TransactionDetail>
             <CustomerTransactionId>Package Tracker Ruby Gem</CustomerTransactionId>
           </TransactionDetail>
           <Version>
             <ServiceId>trck</ServiceId>
             <Major>3</Major>
             <Intermediate>0</Intermediate>
             <Minor>0</Minor>
           </Version>
           <PackageIdentifier>
             <Value>#{tracking_number}</Value>
             <Type>TRACKING_NUMBER_OR_DOORTAG</Type>
           </PackageIdentifier>
           <IncludeDetailedScans>1</IncludeDetailedScans>
         </TrackRequest>
        "
      end

      def parse_response(tracking_number, response)
        handle_errors(response)

        tracking_response = Response.new(tracking_number, self)
        
        # puts Nokogiri::XML(response.body)
        
        Nokogiri::XML(response.body).xpath("//v3:Events").each do |event|
          # puts "IN HERE???????"
          puts event.xpath("v3:EventDescription").text
          puts event.xpath("v3:Timestamp").text
          
          puts ""
          puts ""
          # tracking_response.add_status(
          #   activity.css("Status Description").text,
          #   Time.parse(activity.css("Date").text) + activity.css("Time").text.to_i,
          #   "#{activity.css("City Address").text}, #{activity.css("City StateProvinceCode").text}, #{activity.css("City StateProvinceCode").text}"
          # )
        end
        tracking_response
      end
      
      def handle_errors(response)
        
      end

    end
  end
end