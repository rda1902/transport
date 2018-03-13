module Estimate
  class PositionApproxymator
    MAX_TIME_APPROXIMATE = 180

    def self.run(transports)
      transports.delete_if { |t| t.positions.blank? }
      transports.delete_if { |t| (t.position_last.timestamp + 10.minutes) < Time.now }
      transports.each do |transport|
        new.get_estimated_location_points(transport)
      end
    end

    def get_estimated_location_points(transport)
      @transport = transport
      @last_position = @transport.position_last

      if @last_position.shape_inits(@transport.shapes).blank?
        Logger.debug "Shape was not found! vehicle_id: #{@transport.vehicle_id}
                      Route_id #{@last_position.route_id} not found!"
        @transport.positions.pop
        return
      end

      @route_shapes = @transport.shapes

      @route = @transport.route

      if @route.blank?
        Logger.debug "Route_id #{@last_position.route_id} not found!"
        return
      end

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
      # puts 'first_interaction'

      # set speed
      @transport.average_speed.init_default_speed(@last_position.velocity.to_f)

      @transport.estimated_positions.clear
      nearest_shape_index = @route_shapes.index { |s| s.shape_pt_lat == @last_position.shape.shape_pt_lat && s.shape_pt_lon == @last_position.shape.shape_pt_lon }

      estimate_position = EstimatedPosition.new
      estimate_position.shape_id = @last_position.shape.id
      estimate_position.distance = 0
      estimate_position.shape_index = nearest_shape_index
      estimate_position.lat = @last_position.shape.shape_pt_lat
      estimate_position.lon = @last_position.shape.shape_pt_lon
      estimate_position.timestamp = @last_position.timestamp
      estimate_position.route_id = @last_position.route_id
      estimate_position.direction_id = @last_position.direction_id
      @transport.estimated_positions << estimate_position

      i = 1
      loop do
        next_shape_index = nearest_shape_index + i
        break if next_shape_index > @route_shapes.size - 1
        previous_estimated_position = @transport.estimated_position_last
        next_shape = @route_shapes[next_shape_index]
        distance = GeoMethod.distance([previous_estimated_position.lat, previous_estimated_position.lon], [next_shape.shape_pt_lat, next_shape.shape_pt_lon])
        elapsed_time = distance / @transport.average_speed.speed_meters_in_seconds # meters in seconds
        elapsed_timestamp = previous_estimated_position.timestamp + elapsed_time.seconds

        estimate_position = EstimatedPosition.new
        estimate_position.shape_id = next_shape.id
        estimate_position.distance = distance
        estimate_position.lat = next_shape.shape_pt_lat
        estimate_position.lon = next_shape.shape_pt_lon
        estimate_position.shape_index = next_shape_index
        estimate_position.timestamp = elapsed_timestamp
        estimate_position.route_id = previous_estimated_position.route_id
        estimate_position.direction_id = previous_estimated_position.direction_id
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
      # puts @transport.estimated_positions.size
      # puts "time #{@transport.estimated_position_last.timestamp.to_i - @transport.estimated_positions.first.timestamp.to_i}"
    end

    def next_interaction
      # puts 'next_interaction'
      # delete_estimated_positions
      # puts 'points 1: ' + @transport.estimated_positions.size.to_s

      ep_position_by_time_now = @transport.estimated_positions.sort_by { |ep| (ep.timestamp.to_i - Time.now.to_i).abs }.first

      if @last_position.calculated == false
        # nearest_ep_by_last_position = @transport.estimated_positions.sort_by { |ep| (ep.timestamp.to_i - @last_position.timestamp.to_i).abs }.first
        nearest_shape_index_by_last_position = @route_shapes.index(@route_shapes.min_by { |shape| GeoMethod.distance([@last_position.lat, @last_position.lon], [shape.shape_pt_lat, shape.shape_pt_lon]) })
        speed_was = @transport.average_speed.speed
        if nearest_shape_index_by_last_position < ep_position_by_time_now.shape_index # прогноз убежал вперед, большая скорость ТС, нужно корректировать скорость
          dis = Util.distance_between_shapes(nearest_shape_index_by_last_position, ep_position_by_time_now.shape_index, @route_shapes)
          if dis > 50
            if dis < 200
              @transport.average_speed.correct(-2.0)
            elsif dis < 500
              @transport.average_speed.correct(-4.0)
            elsif dis < 1000
              @transport.average_speed.correct(-12.0)
            elsif dis < 1500
              @transport.average_speed.correct(-15.0)
            else
              @transport.average_speed.correct(-30)
            end
          end
          puts "+++ vehicle_id: #{@transport.vehicle_id}, прогноз убежал вперед: #{dis}
          средняя скорость: #{@transport.average_speed.speed.to_s.red} км/ч (была #{speed_was.to_s.green}),
          #{nearest_shape_index_by_last_position}: #{ep_position_by_time_now.shape_index} "

        elsif nearest_shape_index_by_last_position > ep_position_by_time_now.shape_index # прогноз тормозит, маленькая скорость ТС, нужно корректировать скорость
          dis = Util.distance_between_shapes(ep_position_by_time_now.shape_index, nearest_shape_index_by_last_position, @route_shapes)
          if dis > 50
            if dis < 200
              @transport.average_speed.correct(2.0)
            elsif dis < 500
              @transport.average_speed.correct(4.0)
            elsif dis < 1000
              @transport.average_speed.correct(12.0)
            elsif dis < 1500
              @transport.average_speed.correct(15)
            else
              @transport.average_speed.correct(30)
            end
          end
          puts "--- vehicle_id: #{@transport.vehicle_id}, прогноз тормозит: #{dis}
          средняя скорость: #{@transport.average_speed.speed.to_s.red} км/ч (была #{speed_was.to_s.green}),
          #{nearest_shape_index_by_last_position}: #{ep_position_by_time_now.shape_index} "
        elsif ep_position_by_time_now.shape_index == @transport.estimated_positions.first.shape_index
          return if @transport.estimated_positions.size > 1 && (@transport.estimated_position_last.timestamp.to_i - Time.now.to_i) > 20
        end
      end

      nearest_last_estimated_position = ep_position_by_time_now

      return first_interaction if nearest_last_estimated_position.blank?

      new_estimated_positions = []
      # nearest_last_estimated_position.timestamp = Time.now
      new_estimated_positions << nearest_last_estimated_position
      @route_shapes.each_with_index do |sh, index|
        next if nearest_last_estimated_position.shape_index >= index
        previous_estimated_position = new_estimated_positions.last

        distance = GeoMethod.distance([previous_estimated_position.lat, previous_estimated_position.lon], [sh.shape_pt_lat, sh.shape_pt_lon])
        elapsed_time = distance / @transport.average_speed.speed_meters_in_seconds # meters in seconds
        elapsed_timestamp = previous_estimated_position.timestamp + elapsed_time.seconds

        estimate_position = EstimatedPosition.new
        estimate_position.shape_id = sh.id
        estimate_position.distance = distance
        estimate_position.shape_index = index
        estimate_position.lat = sh.shape_pt_lat
        estimate_position.lon = sh.shape_pt_lon
        estimate_position.timestamp = elapsed_timestamp
        estimate_position.route_id = @last_position.route_id
        estimate_position.direction_id = @last_position.direction_id
        new_estimated_positions << estimate_position
        break if (new_estimated_positions.last.timestamp.to_i - new_estimated_positions.first.timestamp.to_i) >= MAX_TIME_APPROXIMATE
      end

      if nearest_last_estimated_position.shape_index.positive?
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

      # puts @transport.estimated_positions.size
      # puts "time #{@transport.estimated_position_last.timestamp.to_i - @transport.estimated_positions.first.timestamp.to_i}"
      # puts 'points 2: ' + @transport.estimated_positions.size.to_s
    end

    def save
      hash = estimated_positions_hash
      begin
        json = Oj.dump(hash, mode: :compat)
      rescue ArgumentError => e
        Logger.info(hash)
        Logger.error(e.inspect)
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
      @transport.estimated_positions.map do |ep|
        @transport.as_json.merge(ep.as_json)
      end
    end
  end
end
