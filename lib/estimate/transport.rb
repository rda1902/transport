module Estimate
  class Transport
    RECENT_POSITION_POINTS = 20
    attr_accessor :vehicle_id
    attr_accessor :positions
    attr_accessor :estimated_positions
    attr_accessor :route
    attr_accessor :shapes
    attr_accessor :direction_id
    attr_accessor :average_speed

    delegate :last, to: :estimated_positions, prefix: :estimated_position, allow_nil: true
    delegate :last, to: :positions, prefix: :position, allow_nil: true

    def initialize
      @positions = []
      @estimated_positions = []
      @average_speed = AverageSpeed.new
    end

    def self.create_from_logger(vehicle)
      transport = new
      transport.vehicle_id = vehicle['vehicleId']
      # init route and shapes
      transport.init_data(vehicle).blank?
      # add position from 'GUP'
      transport.add_position(vehicle).blank?
      Config.instance.transport << transport
    end

    def init_data(vehicle)
      @estimated_positions.clear
      @direction_id = vehicle['directionId']
      @route = Route.find(vehicle['routeId'])
      raise RouteNotFound, "vehicle: #{vehicle}, route_id: #{vehicle['routeId']}" if @route.blank?
      @shapes = Shape.find_all(vehicle['routeId'], vehicle['directionId'])
      raise ShapesNotFound, "vehicle: #{vehicle}" if @shapes.blank?
      self
    end

    def add_position(vehicle)
      last_position = Position.create_from_logger(vehicle)
      return if last_position.blank?
      return nil if @positions.find { |p| p.timestamp == last_position.timestamp }
      # if route or direction_id have been changed, refresh transport data (route and shapes)
      if check_route_and_direction(vehicle)
        return if init_data(vehicle).blank? # route or shapes not found
      end
      # puts last_position.as_json
      last_position.shape_inits(shapes)
      @positions << last_position
    end

    def as_json
      { vehicle_id: vehicle_id, transport_type: route.transport_type,
        route_long_name: route.long_name,
        route_short_name: route.short_name,
        direction_id: direction_id }
    end

    def calculated!
      position_last.calculated = true
      remove_old_positions
    end

    def route_changed?
      position_last.route_id.to_s != estimated_position_last.route_id.to_s
    end

    def direction_changed?
      direction_id.to_i != position_last.direction_id.to_i
    end

    def nearest_shape_index
      nearest_shape = shapes.min_by { |shape| GeoMethod.distance([position_last.lat, position_last.lon], [shape.shape_pt_lat, shape.shape_pt_lon]) }
      shapes.index(nearest_shape)
    end

    private

    def remove_old_positions
      positions.shift(1) if positions.size > RECENT_POSITION_POINTS
    end

    def check_route_and_direction(vehicle)
      vehicle['routeId'].to_s != @route.route_id.to_s || vehicle['directionId'].to_s != @direction_id.to_s
    end
  end
end
