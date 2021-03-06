module Estimate
  class AverageSpeed
    DECREASE = [[50, -1.0], [200, -2.0], [500, -4.0], [1000, -12.0], [1500, -15.0], [Float::INFINITY, -30.0]].freeze
    INCREASE = [[50, 1.0], [200, 2.0], [500, 4.0], [1000, 12.0], [1500, 15.0], [Float::INFINITY, 30.0]].freeze
    attr_accessor :distance_in_meters
    attr_accessor :seconds
    attr_accessor :default_speed

    def initialize
      @default_speed = 0.0
    end

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
      correct_meth(dis, DECREASE)
    end

    def correct_plus(dis)
      correct_meth(dis, INCREASE)
    end

    private

    def correct_meth(dis, values)
      values.each { |v| break correct(v[1]) if dis < v[0] }
    end
  end
end
