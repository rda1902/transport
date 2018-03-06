module Estimate
  class EstimatedPosition
    attr_accessor :lat
    attr_accessor :lon
    attr_accessor :timestamp
    attr_accessor :route_id
    attr_accessor :direction_id
    attr_accessor :shape_id
    attr_accessor :shape_index
    attr_accessor :distance

    def as_json
      { timestamp: timestamp_unix_format, direction: direction_id.to_i, velocity: 0, lat: lat.to_f, lon: lon.to_f, pathId: direction_id.to_i, routeId: route_id.to_i }
    end

    private

    def timestamp_unix_format
      (timestamp.utc.to_time.to_i.to_s + '000').to_i
    end
  end
end
