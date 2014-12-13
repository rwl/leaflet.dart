part of leaflet.geo.projection;

final LonLat = new _LonLat();

/// Simple equirectangular (Plate Carree) projection, used by CRS like
/// EPSG:4326 and Simple.
class _LonLat implements Projection {
  Point2D project(LatLng latlng) {
    return new Point2D(latlng.lng, latlng.lat);
  }

  LatLng unproject(Point2D point) {
    return new LatLng(point.y, point.x);
  }
}
