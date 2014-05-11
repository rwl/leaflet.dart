part of leaflet.geo.crs;

final Simple = new _Simple();

// A simple CRS that can be used for flat non-Earth maps like panoramas or game maps.
class _Simple extends CRS {

  _Simple() : super(proj.LonLat, new Transformation(1, 0, -1, 0), '');

  num scale(num zoom) {
    return math.pow(2, zoom);
  }
}