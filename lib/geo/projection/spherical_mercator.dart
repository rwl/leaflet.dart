part of leaflet.geo.projection;

final SphericalMercator = new _SphericalMercator();

/**
 * Spherical Mercator is the most popular map projection, used by EPSG:3857 CRS used by default.
 */
class _SphericalMercator implements Projection {
  static final double MAX_LATITUDE = 85.0511287798;

  Point2D project(LatLng latlng) {
    final d = LatLng.DEG_TO_RAD,
        max = MAX_LATITUDE,
        lat = math.max(math.min(max, latlng.lat), -max),
        x = latlng.lng * d;
    double y = lat * d;

    y = math.log(math.tan((math.PI / 4) + (y / 2)));

    return new Point2D(x, y);
  }

  LatLng unproject(Point2D point) {
    final d = LatLng.RAD_TO_DEG,
        lng = point.x * d,
        lat = (2 * math.atan(math.exp(point.y)) - (math.PI / 2)) * d;

    return new LatLng(lat, lng);
  }
}