part of leaflet.geo.crs;

final Simple = new _Simple();

/**
 * A simple CRS that maps longitude and latitude into x and y directly. May be used for maps of flat surfaces (e.g. game maps). Note that the y axis should still be inverted (going from bottom to top).
 */
class _Simple extends CRS {

  _Simple() : super(proj.LonLat, new Transformation(1, 0, -1, 0), '');

  num scale(num zoom) {
    return math.pow(2, zoom);
  }
}