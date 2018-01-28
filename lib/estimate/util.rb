class Estimate::Util
  def self.distance_between_shapes(start_index, end_index, shapes)
    distance = 0
    shapes.each_with_index do |shape, index|
      if start_index < index && index <= end_index
        previous_shape = shapes[index - 1]
        distance += GeoMethod.distance([previous_shape.shape_pt_lat, previous_shape.shape_pt_lon], [shape.shape_pt_lat, shape.shape_pt_lon])
      end
    end
    distance
  end
end
