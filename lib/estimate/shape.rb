module Estimate
    class Shape
    attr_accessor :id
    attr_accessor :shape_id
    attr_accessor :shape_pt_lat
    attr_accessor :shape_pt_lon
    attr_accessor :shape_pt_sequence
    attr_accessor :shape_dist_traveled

    def initialize(args)
      @shape_id = args[:id]
      @shape_id = args[:shape_id]
      @shape_pt_lat = args[:shape_pt_lat]
      @shape_pt_lon = args[:shape_pt_lon]
      @shape_pt_sequence = args[:shape_pt_sequence]
      @shape_dist_traveled = args[:shape_dist_traveled]
    end

    def self.find_all(route_id, direction_id)
      shape_id = find_shape_id(route_id, direction_id)
      return nil if shape_id.blank?
      shapes = []
      Estimate::TransportLogger::CONNECTION.exec_params('SELECT * FROM gtfs_shapes where shape_id=$1', [shape_id]) do |result|
        shapes = result.map do |row|
          Estimate::Shape.new(id: row['id'], shape_id: row['shape_id'], shape_pt_lat: row['shape_pt_lat'], shape_pt_lon: row['shape_pt_lon'], shape_pt_sequence: row['shape_pt_sequence'], shape_dist_traveled: row['shape_dist_traveled'])
        end
      end
      shapes
    end

    def self.find_shape_id(route_id, direction_id)
      Estimate::TransportLogger::CONNECTION.exec_params('SELECT * FROM gtfs_trips where route_id=$1 and direction_id=$2', [route_id, direction_id]) do |result|
        result.each do |res|
          next unless Estimate::CalendarService.instance.valid(res['service_id']).blank?
          return res['shape_id']
        end
      end
      nil
    end
  end
end
