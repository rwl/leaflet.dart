part of leaflet.geo.crs;

final EPSG4326 = new _EPSG4326();

/**
 * EPSG4326 is a CRS popular among advanced GIS specialists.
 */
class _EPSG4326 extends CRS {
  _EPSG4326() : super(proj.LonLat, new Transformation(1 / 360, 0.5, -1 / 360, 0.5), 'EPSG:4326');
}
