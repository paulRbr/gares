$LOAD_PATH.unshift(File.dirname(__FILE__)) unless
  $LOAD_PATH.include?(File.dirname(__FILE__)) || $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'json'
require 'hashie'
require 'unidecoder'

require 'gares/base'
require 'gares/station'
require 'gares/station_list'
require 'gares/sales'
require 'gares/services'
require 'gares/search'
require 'gares/string_extensions'
require 'gares/version'
