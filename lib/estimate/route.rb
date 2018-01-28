class Estimate::Route
  attr_accessor :route_id
  attr_accessor :short_name
  attr_accessor :long_name
  attr_accessor :route_type
  attr_accessor :transport_type

  def initialize(args)
    @route_id = args[:route_id]
    @short_name = args[:short_name]
    @long_name = args[:long_name]
    @route_type = args[:route_type]
    @transport_type = args[:transport_type]
  end
end
