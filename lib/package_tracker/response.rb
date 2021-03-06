module PackageTracker
  class Response
    attr_reader :statuses
    attr_reader :tracking_number
    
    def initialize(tracking_number, carrier, statuses=[])
      @tracking_number = tracking_number
      @carrier = carrier
      @statuses = statuses
      sort_statuses!
    end
    
    def add_status(message, time, location="")
      @statuses << { :message => message, :time => time, :location => location }
      sort_statuses!
    end

    def current_status
      @statuses.first
    end
    
    def current_location
      current_status[:location]
    end
    
    def delivered?
      current_status[:message] == @carrier.delivered_status
    end
    
    private
    
    def sort_statuses!
      @statuses.sort_by! { |status| status[:time] }.reverse!
    end
  end
end