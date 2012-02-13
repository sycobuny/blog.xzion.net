#!/usr/bin/env rackup
#

##
# set up required gems
require 'bundler'

Bundler.setup   :default, ENV['RACK_ENV'].to_sym
Bundler.require :default, ENV['RACK_ENV'].to_sym

##
# set up our load paths
$LOAD_PATH.unshift File.expand_path('.',   File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path('lib', File.dirname(__FILE__))

##
# set up the app itself
require 'db/config'
require 'sass_extensions'
require 'app'

##
# run the application
if File.absolute_path($0) == File.absolute_path(__FILE__) or
   File.absolute_path($0) == `which rackup`.chop
    run Sinatra::Application
end
