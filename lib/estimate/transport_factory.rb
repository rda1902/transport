module Estimate
  class TransportFactory
    def self.processing_data(data)
      transport_all = Config.instance.transport
      data['result'].each do |vehicle|
        transport = transport_all.find { |t| t.vehicle_id == vehicle['vehicleId'] }
        begin
          if transport.present?
            transport.add_position(vehicle)
          else
            Transport.create_from_logger(vehicle)
          end
        rescue ShapesNotFound, RouteNotFound
          transport_all.delete_at(transport_all.index(transport)) if transport.present?
        end
      end
    end
  end
end
