module Estimate
  class PositionApproxymator
    MAX_TIME_APPROXIMATE = 180

    def self.run(transports)
      transports.remove_old
      transports.each { |transport| new.estimate_location_points(transport) }
    end

    def estimate_location_points(transport)
      @transport = transport
      @last_position = @transport.position_last
      @route_shapes = @transport.shapes
      @route = @transport.route
      interaction_switcher
      @transport.calculated!
      @transpor
    end

    private

    def interaction_switcher
      # если расчитанных позиций нет то начинаем все с начала или изменился маршрут, или направление
      return first_interaction if @transport.estimated_positions.size.zero?
      return first_interaction if @transport.route_changed?
      return first_interaction if @transport.direction_changed?
      next_interaction
    end

    def first_interaction
      # set speed
      @transport.average_speed.init_default_speed(@last_position.velocity.to_f)
      @transport.estimated_positions.clear
      nearest_shape_index = @transport.nearest_shape_index

      estimate_position = EstimatedPosition.first_position_init(@transport)
      @transport.estimated_positions << estimate_position

      i = 1
      loop do
        next_shape_index = nearest_shape_index + i
        break if next_shape_index > @route_shapes.size - 1
        previous_estimated_position = @transport.estimated_position_last
        next_shape = @route_shapes[next_shape_index]
        distance = GeoMethod.distance([previous_estimated_position.lat, previous_estimated_position.lon], [next_shape.lat, next_shape.lon])
        elapsed_time = distance / @transport.average_speed.speed_meters_in_seconds # meters in seconds
        elapsed_timestamp = previous_estimated_position.timestamp + elapsed_time.seconds

        estimate_position = EstimatedPosition.new(
          shape_id: next_shape.id, distance: distance,
          lat: next_shape.lat, lon: next_shape.lon,
          shape_index: next_shape_index, timestamp: elapsed_timestamp,
          route_id: previous_estimated_position.route_id,
          direction_id: previous_estimated_position.direction_id
        )

        @transport.estimated_positions << estimate_position
        break if (@transport.estimated_position_last.timestamp.to_i - @transport.estimated_positions.first.timestamp.to_i) >= MAX_TIME_APPROXIMATE
        i += 1
      end

      # стоит на месте
      if @transport.estimated_positions.size == 1
        pos = @transport.estimated_positions.first.clone
        pos.timestamp += 60.seconds
        @transport.estimated_positions << pos
      end
      save
    end

    def next_interaction
      nearest_ep_by_time_now = @transport.nearest_ep_by_time_now
      if nearest_ep_by_time_now.shape_index == @transport.estimated_positions.first.shape_index
        return if @transport.estimated_positions.not_overdue?
      end
      @transport.correct_speed

      new_estimated_positions = EstimatedPositions.new
      new_estimated_positions << nearest_ep_by_time_now
      @route_shapes.each_with_index do |sh, index|
        next if nearest_ep_by_time_now.shape_index >= index
        previous_estimated_position = new_estimated_positions.last

        distance = GeoMethod.distance([previous_estimated_position.lat, previous_estimated_position.lon], [sh.lat, sh.lon])
        elapsed_time = distance / @transport.average_speed.speed_meters_in_seconds # meters in seconds
        elapsed_timestamp = previous_estimated_position.timestamp + elapsed_time.seconds

        estimate_position = EstimatedPosition.new(
          shape_id: sh.id, distance: distance, shape_index: index,
          lat: sh.lat, lon: sh.lon,
          timestamp: elapsed_timestamp, route_id: @last_position.route_id,
          direction_id: @last_position.direction_id
        )
        new_estimated_positions << estimate_position
        break if (new_estimated_positions.last.timestamp.to_i - new_estimated_positions.first.timestamp.to_i) >= MAX_TIME_APPROXIMATE
      end

      if nearest_ep_by_time_now.shape_index.positive?
        # add previous position
        pos = @transport.estimated_positions.find { |ep| ep.shape_index == new_estimated_positions.first.shape_index - 1 }
        new_estimated_positions.unshift(pos.clone) if pos.present?
      end

      # стоит на месте
      if new_estimated_positions.size == 1
        pos = new_estimated_positions.first.clone
        pos.timestamp += 60.seconds
        new_estimated_positions << pos
      end

      @transport.estimated_positions = new_estimated_positions
      save
    end

    def save
      hash = estimated_positions_hash
      begin
        json = Oj.dump(hash, mode: :compat)
      rescue ArgumentError => e
        Logger.info(hash)
        Logger.error(e.full_message)
        return
      else
        Config.instance.redis.setex(key, MAX_TIME_APPROXIMATE, json)
      end
    end

    def delete_estimated_positions
      Config.instance.redis.del(key)
    end

    def key
      "spbtr:#{@transport.vehicle_id}"
    end

    def estimated_positions_hash
      @transport.estimated_positions.as_json(@transport.as_json)
    end
  end
end
