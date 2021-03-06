module Estimate
  class TransportLogger
    REQUEST_INTERVAL = 5
    URL = 'http://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,trolley,tram&bbox=29.498291,60.384005,30.932007,59.684381'.freeze
    # URL = 'http://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,tram&bbox=30.330338992624405,59.94716100016144,30.37660500737556,59.907160999838474'.freeze

    def initialize
      @config = Config.instance
      @config.redis.flushdb
    end

    def request_data
      uri = URI(URL)
      result_json = { 'result' => [] }
      begin
        response = Net::HTTP.get(uri)
        result_json = Oj.load(response)
      rescue StandardError => e
        Logger.error(e.full_message)
      end
      result_json
    end

    def run
      Logger.info('app start')
      loop do
        processing_data
        position_approxymator
        puts @config.transport.size
        puts @config.redis.keys.size
        sleep REQUEST_INTERVAL
      end
    end

    private

    def processing_data
      puts 'processing_data'
      data = request_data
      puts Benchmark.measure('processing_data') {
        TransportFactory.processing_data(data)
      }
    end

    def position_approxymator
      puts 'position_approxymator'
      puts Benchmark.measure('position_approxymator') {
        PositionApproxymator.run(Config.instance.transport)
      }
    end
  end
end
