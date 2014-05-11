part of leaflet.geo.crs;

final EPSG3395 = new _EPSG3395();

class _EPSG3395 extends CRS {
  static final _scale = 0.5 / (math.PI * proj.Mercator.R_MAJOR);

  _EPSG3395() : super(proj.Mercator, new Transformation(_scale, 0.5, -_scale, 0.5), 'EPSG:3395');
}