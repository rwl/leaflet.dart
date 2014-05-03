library leaflet.geo.projection;

import 'dart:math' as math;

// Mercator projection that takes into account that the Earth is not a perfect sphere.
// Less popular than spherical mercator; used by projections like EPSG:3395.
class Mercator {
  static double MAX_LATITUDE = 85.0840591556;

  static double R_MINOR = 6356752.314245179;
  static double R_MAJOR = 6378137;

  project(latlng) { // (LatLng) -> Point
    var d = L.LatLng.DEG_TO_RAD,
        max = this.MAX_LATITUDE,
        lat = math.max(math.min(max, latlng.lat), -max),
        r = this.R_MAJOR,
        r2 = this.R_MINOR,
        x = latlng.lng * d * r,
        y = lat * d,
        tmp = r2 / r,
        eccent = math.sqrt(1.0 - tmp * tmp),
        con = eccent * math.sin(y);

    con = math.pow((1 - con) / (1 + con), eccent * 0.5);

    var ts = math.tan(0.5 * ((math.PI * 0.5) - y)) / con;
    y = -r * math.log(ts);

    return new Point(x, y);
  }

  unproject(point) { // (Point, Boolean) -> LatLng
    var d = L.LatLng.RAD_TO_DEG,
        r = this.R_MAJOR,
        r2 = this.R_MINOR,
        lng = point.x * d / r,
        tmp = r2 / r,
        eccent = math.sqrt(1 - (tmp * tmp)),
        ts = math.exp(- point.y / r),
        phi = (math.PI / 2) - 2 * math.atan(ts),
        numIter = 15,
        tol = 1e-7,
        i = numIter,
        dphi = 0.1,
        con;

    while ((dphi.abs() > tol) && (--i > 0)) {
      con = eccent * math.sin(phi);
      dphi = (math.PI / 2) - 2 * math.atan(ts *
          math.pow((1.0 - con) / (1.0 + con), 0.5 * eccent)) - phi;
      phi += dphi;
    }

    return new LatLng(phi * d, lng);
  }
}