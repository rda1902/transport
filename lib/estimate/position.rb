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

    def initialize(args = {})
      @lon = args.dig(:lon)
      @lat = args.dig(:lat)
      @direction = args.dig(:direction)
      @timestamp = args.dig(:timestamp)
      @velocity = args.dig(:velocity)
      @route_id = args.dig(:routeId)
      @direction_id = args.dig(:directionId)
      @vehicle_label = args.dig(:vehicleLabel)
      @license_plate = args.dig(:licensePlate)
      @order_number = args.dig(:orderNumber)
      @calculated = false
    end

    def self.create_from_logger(data)
      new(
        lon: data.dig('position', 'lon'), lat: data.dig('position', 'lat'),
        direction: data['direction'],
        timestamp: Time.parse("#{data['timestamp']} +0300"),
        velocity: data['velocity'], route_id: data['routeId'],
        direction_id: data['directionId'], vehicle_label: data['vehicleLabel'],
        license_plate: data['licensePlate'], order_number: data['orderNumber']
      )
    end

    def shape_inits(shapes)
      nearest_shape = shapes.min_by { |shape| GeoMethod.distance([lat, lon], [shape.shape_pt_lat, shape.shape_pt_lon]) }
      @nearest_shape_index = shapes.index(nearest_shape)
      @nearest_shape_id = nearest_shape.id
      @shape = nearest_shape
    end
  end
end
