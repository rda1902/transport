require 'net/http'
require 'redis'
require 'oj'
require 'benchmark'
module Estimate
  class TransportLogger
    CONNECTION = PG.connect(ENV['DATABASE_URL'])
    REDIS = Redis.new

    REQUEST_INTERVAL = 5
    URL = 'http://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,trolley,tram&bbox=29.498291,60.384005,30.932007,59.684381'.freeze
    # URL = 'http://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,tram&bbox=30.330338992624405,59.94716100016144,30.37660500737556,59.907160999838474'.freeze

    def request_data
      uri = URI(URL)
      result_json = { 'result' => [] }
      begin
        response = Net::HTTP.get(uri)
        result_json = Oj.load(response)
      rescue StandardError => e
        puts e.inspect
      end
      result_json
    end

    def run
      Estimate::TransportLogger::REDIS.flushdb
      loop do
        data = request_data
        puts 'processing_data'
        puts Benchmark.measure {
          Estimate::TransportFactory.processing_data(data)
        }
        puts 'position_approxymator'
        puts Benchmark.measure {
          Estimate::PositionApproxymator.run(Estimate::TransportFactory::TRANSPORT)
        }
        puts Estimate::TransportFactory::TRANSPORT.size
        puts Estimate::TransportLogger::REDIS.keys.size
        sleep REQUEST_INTERVAL
      end
    end
  end
end
