class Estimate::TransportFactory
  TRANSPORT = []
  def self.processing_data(data)
    data['result'].each do |vehicle|
      transport = TRANSPORT.find { |t| t.vehicle_id == vehicle['vehicleId'] }
      if transport.present?
        transport.add_position(vehicle)
      else
        Estimate::Transport.create_from_logger(vehicle)
      end
    end
  end
end
