module PackageTracker
  module Carriers
    module USPS
      extend Carrier
      extend self
      
      LIVE_URL = "production.shippingapis.com"
      LIVE_PATH = "/ShippingAPI.dll"
      TEST_URL = "testing.shippingapis.com"
      TEST_PATH = "/ShippingAPITest.dll"
      
      
      def name
        "USPS"
      end
      
      def track(tracking_number, options)
        validate_credentials!(options[:credentials])
        repsonse = Request.post(request_url(options[:testing]), request_path(options[:testing]), request_data(tracking_number, options[:credentials]))
        parse_response(tracking_number, repsonse)
      end
      
      def match(tracking_number)
        tracking_number =~ /^\d{20}$/ || tracking_number =~ /^\d{30}$/ || tracking_number =~ /^[A-Za-z]{2}\d{9}[A-Za-z]{2}$/
      end
      
      def delivered_status
        "delivered"
      end

      
      private
      
      def required_credentials
        [:user_id, :password]
      end
      
      def request_url(testing)
        testing ? TEST_URL : LIVE_URL
      end
      
      def request_path(testing)
        testing ? TEST_PATH : LIVE_PATH
      end
      
      def request_data(tracking_number, credentials)
        "API=TrackV2&XML=<TrackRequest USERID='#{credentials[:user_id]}'><TrackID ID='#{tracking_number}'></TrackID></TrackRequest>"
      end
      
      def parse_response(tracking_number, response)
        handle_errors(response)
        
        tracking_response = Response.new(tracking_number, self)
        document = Nokogiri::XML(response.body)
        
        summary = parse_summary(document.css("TrackSummary").text)
        tracking_response.add_status(summary[:message], summary[:time], summary[:location])
        
        document.css("TrackDetail").each do |status|
          detail = parse_detail(status.text)
          tracking_response.add_status(detail[:message], detail[:time], detail[:location])
        end
        tracking_response
      end
      
      def handle_errors(response)
        document = Nokogiri::XML(response.body)
        raise InvalidCredentialsError if document.css("Error Number").text == "80040b1a"
        raise InvalidTrackingNumberError if document.css("TrackSummary").text =~ /There is no record of that mail item/
      end
      
      def parse_detail(detail)
        match = detail.match(/(.*) (NOTICE LEFT) (.*)\./) ||
                detail.match(/(.*) (ARRIVAL AT UNIT) (.*)\./) ||
                detail.match(/(.*) (ACCEPT OR PICKUP) (.*)\./)

        {:message => match[2], :time => Time.parse(match[1]), :location => match[3]}
      end
      
      def parse_summary(summary)
        if match = summary.match(/Your item was (delivered) at (.*) on (.*) in (.*)\./)
          {:message => match[1], :time => Time.parse("#{match[3]} #{match[2]}"), :location => match[4]}
        end
      end
      
    end
  end
end