$LOAD_PATH.unshift(File.dirname(__FILE__)) unless
  $LOAD_PATH.include?(File.dirname(__FILE__)) || $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'json'
require 'hashie'
require 'smarter_csv'
require 'unidecoder'
require 'httparty'
require 'attribute_accessors'
require 'string_extensions'

require 'gares/errors'
require 'gares/base'
require 'gares/station'
require 'gares/station_list'
require 'gares/search'
require 'gares/train'
require 'gares/train_stop'
require 'gares/version'
