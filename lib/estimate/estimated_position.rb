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
      { shape_index: shape_index, route_id: route_id,
        timestamp: (timestamp.to_i.to_s + '000').to_i,
        lat: lat, lon: lon }
    end

    private

    def timestamp_unix_format
      (timestamp.utc.to_time.to_i.to_s + '000').to_i
    end
  end
end
