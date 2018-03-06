module Estimate
  class TransportFactory
    TRANSPORT = []
    def self.processing_data(data)
      data['result'].each do |vehicle|
        transport = TRANSPORT.find { |t| t.vehicle_id == vehicle['vehicleId'] }
        begin
          if transport.present?
            transport.add_position(vehicle)
          else
            Estimate::Transport.create_from_logger(vehicle)
          end
        rescue Estimate::ShapesNotFound
          TRANSPORT.delete_at(TRANSPORT.index(transport)) if transport.present?
        end
      end
    end
  end
end
