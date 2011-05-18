module PackageTracker
  module Carriers
    module USPS
      extend Carrier
      extend self
      
      def match(tracking_number)
        tracking_number =~ /^\d{20}$/ || tracking_number =~ /^\d{30}$/ || tracking_number =~ /^[A-Za-z]{2}\d{9}[A-Za-z]{2}$/
      end
    end
  end
end