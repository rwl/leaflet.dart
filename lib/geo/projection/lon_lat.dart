part of leaflet.geo.projection;

final LonLat = new _LonLat();

/**
 * Simple equirectangular (Plate Carree) projection, used by CRS like EPSG:4326 and Simple.
 */
class _LonLat implements Projection {
  geom.Point project(LatLng latlng) {
    return new geom.Point(latlng.lng, latlng.lat);
  }

  LatLng unproject(geom.Point point) {
    return new LatLng(point.y, point.x);
  }
}