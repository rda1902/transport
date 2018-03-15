module Estimate
  class Config
    include Singleton
    attr_reader :transport
    attr_reader :redis
    attr_reader :connection

    def initialize
      @transport = Transports.new
      @redis = Redis.new
      @connection = PG.connect(ENV['DATABASE_URL'])
    end
  end
end
