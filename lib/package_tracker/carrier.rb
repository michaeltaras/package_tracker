module PackageTracker
  module Carrier
    def validate_credentials!(credentials)
      required_credentials.each do |key| 
        raise MissingCredentialsError, "You must provide a #{key} in the options" unless credentials && credentials[key]
      end
    end
  end
end
