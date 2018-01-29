class Estimate::Transport
  attr_accessor :vehicle_id
  attr_accessor :positions
  attr_accessor :estimated_positions
  attr_accessor :route
  attr_accessor :shapes
  attr_accessor :direction_id
  attr_accessor :average_speed

  def initialize
    @positions = []
    @estimated_positions = []
    @average_speed = Estimate::AverageSpeed.new
  end

  def self.create_from_logger(vehicle)
    transport = new
    transport.vehicle_id = vehicle['vehicleId']
    transport.direction_id = vehicle['directionId']
    return nil if transport.init_data(vehicle).blank?
    return nil if transport.add_position(vehicle).blank?
    Estimate::TransportFactory::TRANSPORT << transport
  end

  def init_data(vehicle)
    Estimate::TransportLogger::CONNECTION.exec("SELECT * FROM gtfs_routes where route_id='#{vehicle['routeId']}'") do |result|
      row = result.first
      @route = Estimate::Route.new(route_id: row['route_id'], short_name: row['short_name'], long_name: row['long_name'], route_type: row['route_type'], transport_type: row['transport_type'])
    end
    shape_id = nil
    Estimate::TransportLogger::CONNECTION.exec("SELECT * FROM gtfs_trips where route_id='#{vehicle['routeId']}' and direction_id='#{vehicle['directionId']}'") do |result|
      return nil  if result.values.size.zero?
      shape_id = result.first['shape_id']
    end
    return nil if shape_id.blank?
    @shapes = []
    Estimate::TransportLogger::CONNECTION.exec("SELECT * FROM gtfs_shapes where shape_id='#{shape_id}'") do |result|
      result.each do |row|
        @shapes << Estimate::Shape.new(id: row['id'], shape_id: row['shape_id'], shape_pt_lat: row['shape_pt_lat'], shape_pt_lon: row['shape_pt_lon'], shape_pt_sequence: row['shape_pt_sequence'], shape_dist_traveled: row['shape_dist_traveled'])
      end
    end
    return nil if shapes.blank?
    self
  end

  def init_dataOLD(vehicle)
    self.route = Gtfs::Route.find_by(route_id: vehicle['routeId']).to_estimate
    shape_id = Gtfs::Trip.find_by(route_id: vehicle['routeId'], direction_id: vehicle['directionId'])&.shape_id
    return nil if shape_id.blank?
    self.shapes = Gtfs::Shape.where(shape_id: shape_id).map(&:to_estimate)
    return nil if shapes.blank?
    self
  end

  def add_position(vehicle)
    last_position = Estimate::Position.create_from_logger(vehicle)
    return if last_position.blank?
    return nil if @positions.find { |p| p.timestamp == last_position.timestamp }
    if vehicle['routeId'].to_s != route.route_id.to_s || vehicle['directionId'].to_s != direction_id.to_s
      return if init_data(vehicle).blank? # route ar shapes not found
    end

    # puts last_position.as_json
    @positions << last_position
  end

  def as_json
    { vehicleId: vehicle_id.to_i, transportType: route.transport_type, routeShortName: route.short_name, routeLongName: route.long_name, routeId: route.route_id.to_i, positions: estimated_positions.map(&:as_json) }
  end
end
