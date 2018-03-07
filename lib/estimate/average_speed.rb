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
      @default_speed
    end

    def speed_meters_in_seconds
      speed_temp = (((@default_speed * 1000) / 60) / 60)
      speed_temp = 0.1 if speed_temp <= 0
      speed_temp.round(2)
    end
  end
end
