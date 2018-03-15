module Estimate
  class Transports < Array
    MAX_TIME_REFRESH = 10.minutes

    def remove_old
      delete_if { |t| t.positions.blank? }
      delete_if { |t| (t.position_last.timestamp + MAX_TIME_REFRESH) < Time.now }
    end

    def create_transport_from_logger(vehicle)
      transport = Transport.new
      transport.vehicle_id = vehicle['vehicleId']
      # init route and shapes
      transport.init_data(vehicle).blank?
      # add position from 'GUP'
      transport.add_position(vehicle).blank?
      self << transport
    end

    def find_by_vehicle_id(vehicle_id)
      find { |t| t.vehicle_id == vehicle_id }
    end
  end
end
