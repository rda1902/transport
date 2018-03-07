module Estimate
  Logger = Logger.new("#{File.dirname(__FILE__)}/../log/transport.log", 5, 5.megabytes, level: :debug)
end
