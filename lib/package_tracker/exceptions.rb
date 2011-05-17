module PackageTracker
  # Generic PackageTracker Error
  class PackageTrackerError < StandardError; end
  
  # Invalid username/password is posted to the server
  class InvalidCredentialsError < PackageTrackerError; end
  
  # The needed credentials to communicate with the server were not given
  class MissingCredentialsError < PackageTrackerError; end
    
  # The tracking number given was invalid
  class InvalidTrackingNumberError < PackageTrackerError; end
  
  # The carrier for the tracking number could not be discerned
  class CarrierNotFoundError < PackageTrackerError; end
end