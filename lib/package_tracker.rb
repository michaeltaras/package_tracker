$:.unshift File.dirname(__FILE__)

# Gems
require 'rubygems'
require 'nokogiri'

# Standard Lib
require 'uri'
require 'net/http'
require 'net/https'
require 'pp'

# Local Files
require 'package_tracker/request'
require 'package_tracker/carrier'
require 'package_tracker/carriers/ups'

module PackageTracker
end

ups_tracker = PackageTracker::UPS.new(:key => "7C7C172CCF7747B8", :user_id => "michaeltaras", :password => "mtinsc")
doc = Nokogiri::XML(ups_tracker.track("1Z12345E0291980793"))

pp doc
