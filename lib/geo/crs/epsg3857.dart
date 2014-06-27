part of leaflet.geo.crs;

final EPSG3857 = new _EPSG3857();

/**
 * EPSG3857 (Spherical Mercator) is the most common CRS for web mapping
 * and is used by Leaflet by default.
 */
class _EPSG3857 extends CRS {

  static final num earthRadius = 6378137;

  _EPSG3857([String code = 'EPSG:3857']) : super(proj.SphericalMercator, new Transformation(0.5 / math.PI, 0.5, -0.5 / math.PI, 0.5), code);

  Point2D project(LatLng latlng) { // (LatLng) -> Point
    final projectedPoint = this.projection.project(latlng);
    return projectedPoint.multiplyBy(earthRadius);
  }
}

final EPSG900913 = new _EPSG900913();

class _EPSG900913 extends _EPSG3857 {
  _EPSG900913() : super('EPSG:900913');
}