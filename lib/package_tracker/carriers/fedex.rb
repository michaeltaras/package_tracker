module PackageTracker
  module Carriers
    module FedEx
      extend Carrier
      extend self
      
      TEST_URL = 'gatewaybeta.fedex.com'
      LIVE_URL = 'gateway.fedex.com'
    
      PATH = "/xml"
      PORT = "443"
      
      def name
        "FedEx"
      end
        
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
      
      def match(tracking_number)
        tracking_number =~ /^\w{9}$/ || tracking_number =~ /^\d{12,15}$/ || tracking_number =~ /^96\d{20}$/
      end
      
      def delivered_status
        "Delivered"
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
        Nokogiri::XML(response.body).xpath("//v3:Events").each do |event|
          location = unless event.xpath("v3:Address//v3:City").empty?
            "#{event.xpath("v3:Address//v3:City").text}, " +
            "#{event.xpath("v3:Address//v3:StateOrProvinceCode").text}, " + 
            "#{event.xpath("v3:Address//v3:CountryCode").text}"
          end
          
          tracking_response.add_status(
            event.xpath("v3:EventDescription").text,
            Time.parse(event.xpath("v3:Timestamp").text),
            location
          )
        end
        tracking_response
      end
      
      def handle_errors(response)
        document = Nokogiri::XML(response.body)
        if document.children.first.namespace.prefix == "ns"
          raise InvalidCredentialsError if document.xpath("//ns:Notifications//ns:Code").text == "1000"
        elsif document.children.first.namespace.prefix == "v3"
          raise InvalidTrackingNumberError if document.xpath("//v3:Notifications//v3:Code").text == "9040"
        end
      end

    end
  end
end