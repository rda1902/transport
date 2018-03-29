require 'daemons'
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

options = {
  keep_pid_files: true,
  dir_mode: :script,
  dir: __dir__
}

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |file| require file }

Daemons.run_proc('transport.rb', options) do
  Estimate::TransportLogger.new.run
end
