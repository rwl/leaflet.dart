part of leaflet.geo.projection;

final Mercator = new MercatorProjection();

/**
 * Mercator projection that takes into account that the Earth is not a perfect sphere.
 *
 * Less popular than spherical mercator; used by projections like EPSG:3395.
 */
class MercatorProjection implements Projection {
  static double MAX_LATITUDE = 85.0840591556;

  static double R_MINOR = 6356752.314245179;
  static double R_MAJOR = 6378137.0;

  Point2D project(LatLng latlng) {
    final d = LatLng.DEG_TO_RAD,
        max = MAX_LATITUDE,
        lat = math.max(math.min(max, latlng.lat), -max),
        r = R_MAJOR,
        r2 = R_MINOR,
        x = latlng.lng * d * r,
        tmp = r2 / r,
        eccent = math.sqrt(1.0 - tmp * tmp);
    double y = lat * d;
    double con = eccent * math.sin(y);

    con = math.pow((1 - con) / (1 + con), eccent * 0.5);

    final ts = math.tan(0.5 * ((math.PI * 0.5) - y)) / con;
    y = -r * math.log(ts);

    return new Point2D(x, y);
  }

  LatLng unproject(Point2D point) {
    final d = LatLng.RAD_TO_DEG,
        r = R_MAJOR,
        r2 = R_MINOR,
        lng = point.x * d / r,
        tmp = r2 / r,
        eccent = math.sqrt(1 - (tmp * tmp)),
        ts = math.exp(- point.y / r),
        numIter = 15,
        tol = 1e-7;
    int i = numIter;
    double dphi = 0.1;
    double phi = (math.PI / 2) - 2 * math.atan(ts);

    while ((dphi.abs() > tol) && (--i > 0)) {
      final con = eccent * math.sin(phi);
      dphi = (math.PI / 2) - 2 * math.atan(ts *
          math.pow((1.0 - con) / (1.0 + con), 0.5 * eccent)) - phi;
      phi += dphi;
    }

    return new LatLng(phi * d, lng);
  }
}