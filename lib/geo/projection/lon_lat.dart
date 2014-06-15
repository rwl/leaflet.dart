part of leaflet.geo.projection;

final LonLat = new _LonLat();

/**
 * Simple equirectangular (Plate Carree) projection, used by CRS like EPSG:4326 and Simple.
 */
class _LonLat implements Projection {
  project(latlng) {
    return new Point(latlng.lng, latlng.lat);
  }

  unproject(point) {
    return new LatLng(point.y, point.x);
  }
}