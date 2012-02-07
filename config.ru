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
require 'db/config.rb'
require 'app'

##
# run the application
run Sinatra::Application
