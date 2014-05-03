library leaflet.geo.crs;

import 'dart:math' as math;

// A simple CRS that can be used for flat non-Earth maps like panoramas or game maps.
class Simple {
  var projection = projection.LonLat;
  var transformation = new Transformation(1, 0, -1, 0);

  scale(zoom) {
    return math.pow(2, zoom);
  }
}