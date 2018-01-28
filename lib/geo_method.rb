class GeoMethod
  def self.distance(loc1, loc2)
    (::Geocoder::Calculations.distance_between(loc1, loc2).round(3) * 1000 * 1.6).to_i
  end

  def self.bbox_include_points?(bbox, latitude, longitude) # TODO: отрефакторить!
    bbox = bbox.split(',')
    neLatitude = bbox[0].to_f
    neLongitude = bbox[1].to_f
    swLatitude = bbox[2].to_f
    swLongitude = bbox[3].to_f

    longitudeContained = false
    latitudeContained = false

    if swLongitude < neLongitude
      if swLongitude < longitude && longitude < neLongitude
        longitudeContained = true
      end
    else
      # Contains prime meridian.
      if (0 < longitude && longitude < neLongitude) || (swLongitude < longitude && longitude < 0)
        longitudeContained = true
      end
    end

    if swLatitude < neLatitude
      if swLatitude < latitude && latitude < neLatitude
        latitudeContained = true
      end
    end
    longitudeContained && latitudeContained
  end
end
