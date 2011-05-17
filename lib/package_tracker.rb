$:.unshift File.dirname(__FILE__)

# Gems
require 'rubygems'
require 'nokogiri'
require 'facets'
require 'facets/module/cattr'

# Standard Lib
require 'net/http'
require 'net/https'
require 'time'
require 'uri'

# Local Files
require 'package_tracker/request'
require 'package_tracker/response'
require 'package_tracker/client'
require 'package_tracker/exceptions'
require 'package_tracker/carrier'
require 'package_tracker/carriers/ups'
require 'package_tracker/carriers/fedex'

