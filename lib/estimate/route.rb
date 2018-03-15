module Estimate
  class Route
    attr_accessor :route_id
    attr_accessor :short_name
    attr_accessor :long_name
    attr_accessor :route_type
    attr_accessor :transport_type

    def initialize(args)
      @route_id = args[:route_id]
      @short_name = args[:short_name]
      @long_name = args[:long_name]
      @route_type = args[:route_type]
      @transport_type = args[:transport_type]
    end

    def self.find!(route_id)
      route = find(route_id)
      raise RouteNotFound, "route_id: #{vehicle['routeId']}" if route.blank?
      route
    end

    def self.find(route_id)
      Config.instance.connection.exec_params('SELECT * FROM gtfs_routes where route_id = $1 LIMIT 1', [route_id]) do |result|
        row = result.first
        return new(route_id: row['route_id'],
                   short_name: row['short_name'],
                   long_name: row['long_name'],
                   route_type: row['route_type'],
                   transport_type: row['transport_type'])
      end
    end
  end
end
