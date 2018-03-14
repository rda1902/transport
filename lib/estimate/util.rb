module Estimate
  class Util
    def self.distance_between_shapes(start_index, end_index, shapes)
      distance = 0
      shapes.each_with_index do |shape, index|
        if start_index < index && index <= end_index
          previous_shape = shapes[index - 1]
          distance += GeoMethod.distance([previous_shape.lat, previous_shape.lon], [shape.lat, shape.lon])
        end
      end
      distance
    end
  end
end
