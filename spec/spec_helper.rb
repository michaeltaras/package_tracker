require 'rubygems'
require 'fakeweb'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'package_tracker'

Spec::Runner.configure do |config|
  FakeWeb.allow_net_connect = false
  
  # URI's for the app
  AUTHENTICATED_URI = 'somedude:somepassword@api.trumpet.io'
  UNAUTHENTICATED_URI = 'api.trumpet.io'
end
