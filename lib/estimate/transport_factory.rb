module Estimate
  class TransportFactory
    def self.processing_data(data)
      transport_all = Config.instance.transport
      data['result'].each do |vehicle|
        transport = transport_all.find_by_vehicle_id(vehicle['vehicleId'])
        begin
          if transport.present?
            transport.add_position(vehicle)
          else
            transport_all.create_transport_from_logger(vehicle)
          end
        rescue ShapesNotFound, RouteNotFound => e
          # Logger.error(e.full_message)
          transport_all.delete_at(transport_all.index(transport)) if transport.present?
        end
      end
    end
  end
end
