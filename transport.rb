require 'pg'
require 'active_support/all'
require 'geocoder'
require 'colorize'
require 'dotenv/load'

Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |file| require file }

# puts Estimate::CalendarService.instance.valid(Time.now.to_date).size

Estimate::TransportLogger.new.run
