require 'pg'
require 'active_support/all'
require 'geocoder'
require 'colorize'
require 'dotenv/load'

Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |file| require file }

Estimate::TransportLogger.new.run
