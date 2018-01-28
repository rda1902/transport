class Estimate::Shape
  attr_accessor :id
  attr_accessor :shape_id
  attr_accessor :shape_pt_lat
  attr_accessor :shape_pt_lon
  attr_accessor :shape_pt_sequence
  attr_accessor :shape_dist_traveled

  def initialize(args)
    @shape_id = args[:id]
    @shape_id = args[:shape_id]
    @shape_pt_lat = args[:shape_pt_lat]
    @shape_pt_lon = args[:shape_pt_lon]
    @shape_pt_sequence = args[:shape_pt_sequence]
    @shape_dist_traveled = args[:shape_dist_traveled]
  end

end
