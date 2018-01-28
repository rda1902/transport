class Estimate::AverageSpeed
  attr_accessor :distance_in_meters
  attr_accessor :seconds
  attr_accessor :default_speed

  def set_default_speed(km_in_hour)
    km_in_hour = 15 if km_in_hour <= 0
    @default_speed = ((km_in_hour * 1000) / 60) / 60
  end

  def correct(param)
    @default_speed *= param
  end

  def speed
    @default_speed
    # return @default_speed if @distance_in_meters.zero? || @seconds.zero?
    # @distance_in_meters / @seconds
  end
end
