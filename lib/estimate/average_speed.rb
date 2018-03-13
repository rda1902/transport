module Estimate
  class AverageSpeed
    attr_accessor :distance_in_meters
    attr_accessor :seconds
    attr_accessor :default_speed

    def init_default_speed(km_in_hour)
      km_in_hour = 1 if km_in_hour <= 0
      @default_speed = km_in_hour.to_f
    end

    def correct(param)
      @default_speed += param
      @default_speed = 0.1 if @default_speed <= 0
      @default_speed = 60 if @default_speed >= 60
    end

    def speed
      @default_speed.round(2)
    end

    def speed_meters_in_seconds
      speed_temp = (((@default_speed * 1000) / 60) / 60)
      speed_temp = 0.1 if speed_temp <= 0
      speed_temp.round(2)
    end

    def correct_minus(dis)
      return if dis < 50
      if dis < 200
        correct(-2.0)
      elsif dis < 500
        correct(-4.0)
      elsif dis < 1000
        correct(-12.0)
      elsif dis < 1500
        correct(-15.0)
      else
        correct(-30)
      end
    end

    def correct_plus(dis)
      return if dis < 50
      if dis < 200
        correct(2.0)
      elsif dis < 500
        correct(4.0)
      elsif dis < 1000
        correct(12.0)
      elsif dis < 1500
        correct(15.0)
      else
        correct(30)
      end
    end
  end
end
