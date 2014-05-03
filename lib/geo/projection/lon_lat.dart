library leaflet.geo.projection;

// Simple equirectangular (Plate Carree) projection, used by CRS like EPSG:4326 and Simple.
class LonLat {
  project(latlng) {
    return new L.Point(latlng.lng, latlng.lat);
  }

  unproject(point) {
    return new L.LatLng(point.y, point.x);
  }
}