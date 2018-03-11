require 'pg'
require 'active_support/all'
require 'geocoder'
require 'colorize'
require 'dotenv/load'
require 'logger'
require 'net/http'
require 'redis'
require 'oj'
require 'benchmark'

Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |file| require file }

Estimate::TransportLogger.new.run
