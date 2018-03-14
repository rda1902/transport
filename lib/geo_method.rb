class GeoMethod
  def self.distance(loc1, loc2)
    (::Geocoder::Calculations.distance_between(loc1, loc2).round(3) * 1000 * 1.6).to_i
  end
end
