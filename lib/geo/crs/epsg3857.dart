library leaflet.geo.crs;

import 'dart:math' as math;

// EPSG3857 (Spherical Mercator) is the most common CRS for web mapping
// and is used by Leaflet by default.
class EPSG3857 extends CRS {
  var code = 'EPSG:3857';

  var projection = projection.SphericalMercator;
  var transformation = new L.Transformation(0.5 / Math.PI, 0.5, -0.5 / Math.PI, 0.5);

  project(latlng) { // (LatLng) -> Point
    var projectedPoint = this.projection.project(latlng),
        earthRadius = 6378137;
    return projectedPoint.multiplyBy(earthRadius);
  }
}

class EPSG900913 extends EPSG3857 {
  var code = 'EPSG:900913';
}