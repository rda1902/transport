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

    def initialize(args = {})
      @lat = args.dig :lat
      @lon = args.dig :lon
      @timestamp = args.dig :timestamp
      @route_id = args.dig :route_id
      @direction_id = args.dig :direction_id
      @shape_id = args.dig :shape_id
      @shape_index = args.dig :shape_index
      @distance = args.dig :distance
    end

    def as_json
      { shape_index: shape_index, route_id: route_id,
        timestamp: (timestamp.to_i.to_s + '000').to_i,
        lat: lat, lon: lon }
    end

    def self.first_position_init(transport)
      last_position = transport.position_last
      new(
        shape_id: last_position.shape.id, distance: 0,
        shape_index: transport.nearest_shape_index, lat: last_position.shape_pt_lat,
        lon: last_position.shape_pt_lon,
        timestamp: last_position.timestamp, route_id: last_position.route_id,
        direction_id: last_position.direction_id
      )
    end

    private

    def timestamp_unix_format
      (timestamp.utc.to_time.to_i.to_s + '000').to_i
    end
  end
end
