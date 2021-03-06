module PackageTracker
  class Request
    def self.get(uri, path, body, options={})
      do_request(Net::HTTP::Get, uri, path, body, options)
    end

    def self.post(uri, path, body, options={})
      do_request(Net::HTTP::Post, uri, path, body, options)
    end
    
    def self.do_request(http_method, uri, path, body, options={})      
      raw_request = http_method.new(path)
      raw_request.body = body
      
      http = Net::HTTP.new(uri, options[:port])
      http.use_ssl = true if options[:https]
      
      http.request(raw_request)
    end
  end
end
