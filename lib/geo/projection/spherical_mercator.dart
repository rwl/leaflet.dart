part of leaflet.geo.projection;

final SphericalMercator = new _SphericalMercator();

/**
 * Spherical Mercator is the most popular map projection, used by EPSG:3857 CRS used by default.
 */
class _SphericalMercator implements Projection {
  static final double MAX_LATITUDE = 85.0511287798;

  project(latlng) { // (LatLng) -> Point
    var d = LatLng.DEG_TO_RAD,
        max = MAX_LATITUDE,
        lat = math.max(math.min(max, latlng.lat), -max),
        x = latlng.lng * d,
        y = lat * d;

    y = math.log(math.tan((math.PI / 4) + (y / 2)));

    return new Point(x, y);
  }

  unproject(point) { // (Point, Boolean) -> LatLng
    var d = LatLng.RAD_TO_DEG,
        lng = point.x * d,
        lat = (2 * math.atan(math.exp(point.y)) - (math.PI / 2)) * d;

    return new LatLng(lat, lng);
  }
}