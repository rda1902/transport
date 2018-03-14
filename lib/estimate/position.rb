module Estimate
  class Position
    attr_accessor :lat
    attr_accessor :lon
    attr_accessor :direction
    attr_accessor :timestamp
    attr_accessor :velocity
    attr_accessor :route_id
    attr_accessor :direction_id
    attr_accessor :vehicle_label
    attr_accessor :order_number
    attr_accessor :license_plate
    attr_accessor :nearest_shape_id
    attr_accessor :nearest_shape_index
    attr_accessor :shape
    attr_accessor :calculated

    delegate :shape_pt_lat, to: :shape
    delegate :shape_pt_lon, to: :shape

    def self.create_from_logger(data)
      position = new
      position.lon = data.dig('position', 'lon')
      position.lat = data.dig('position', 'lat')
      position.direction = data['direction']
      position.timestamp = Time.parse("#{data['timestamp']} +0300")
      position.velocity = data['velocity']
      position.route_id = data['routeId']
      position.direction_id = data['directionId']
      position.vehicle_label = data['vehicleLabel']
      position.license_plate = data['licensePlate']
      position.order_number = data['orderNumber']
      position.calculated = false
      position
    end

    def shape_inits(shapes)
      nearest_shape = shapes.min_by { |shape| GeoMethod.distance([lat, lon], [shape.shape_pt_lat, shape.shape_pt_lon]) }
      @nearest_shape_index = shapes.index(nearest_shape)
      @nearest_shape_id = nearest_shape.id
      @shape = nearest_shape
    end
  end
end
