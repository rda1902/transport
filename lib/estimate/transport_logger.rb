require 'net/http'
require 'json'
require 'redis'
require 'oj'
require 'benchmark'
class Estimate::TransportLogger
  # CONNECTION = PG.connect(host: 'localhost', user: 'pguser', password: 'fgio892der', dbname: 'spb_tr')

  CONNECTION = PG.connect('postgres://pguser:fgio892der@localhost/spb_tr')
  # CONNECTION = PG.connect('postgres://postgres:@localhost/spb_transport_dev')
  REDIS = Redis.new

  REQUEST_INTERVAL = 5
  URL = 'http://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,tram&bbox=29.498291,60.384005,30.932007,59.684381'.freeze
  # URL = 'http://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,tram&bbox=30.330338992624405,59.94716100016144,30.37660500737556,59.907160999838474'.freeze

  def request_data
    uri = URI(URL)
    result_json = { 'result' => [] }
    begin
      response = Net::HTTP.get(uri)
      result_json = Oj.load(response)
    rescue => e
      puts e.inspect
    end
    result_json
  end

  def run
    old_positions = {}
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
      
=begin
      puts 'bbox_include_points'
      puts Benchmark.measure {
        vehicles = {}
        bbox = '60.384005,30.932007,59.684381,29.498291'
        Estimate::TransportLogger::REDIS.keys.each do |k|
          next unless k.include?('spbtr:')
          hash = Estimate::TransportLogger::REDIS.get(k)
          #puts hash.class.to_s
          begin
            Oj.load(hash).each do |v|
              if GeoMethod.bbox_include_points?(bbox, v['lat'].to_f, v['lon'].to_f)
                vehicles[v['vehicle_id']] = Oj.load(hash)
                break
              end
            end
          rescue TypeError => e
            puts hash
            puts e.backtrace.join("\n")
            puts e.message
          end
        end
        puts "vehicles.size #{vehicles.size}"
        positions = {}
        vehicles.each do |_k, value|
          value.each do |v|
            unless positions.key? v['vehicle_id']
              positions[v['vehicle_id']] = { vehicleId: v['vehicle_id'].to_i, transportType: v['transport_type'], routeShortName: v['route_short_name'], routeLongName: v['route_long_name'], routeId: v['route_id'].to_i, positions: [] }
            end
            positions[v['vehicle_id']][:positions] << { timestamp: v['timestamp'], direction: v['direction_id'].to_i, velocity: 0, lat: v['lat'].to_f, lon: v['lon'].to_f, pathId: v['direction_id'].to_i, routeId: v['route_id'].to_i }
          end
        end

        puts "positions #{positions.size}"
        refreshed_positions = {}
        positions.each do |k, v|
          if old_positions[k].blank?
            refreshed_positions[k] = v
          elsif old_positions[k][:positions].last[:timestamp] != positions[k][:positions].last[:timestamp]
            refreshed_positions[k] = v
          end
        end
        old_positions = positions
        puts "refreshed_positions #{refreshed_positions.size}"



        #hash = positions.map { |_k, v| v }
        #puts Oj.dump(hash)
      }
=end
      sleep REQUEST_INTERVAL
    end
  end
end
