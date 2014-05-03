library leaflet.geo.crs;

// EPSG4326 is a CRS popular among advanced GIS specialists.
class EPSG4326 extends CRS {
  var code = 'EPSG:4326';

  var projection = projection.LonLat;
  var transformation = new Transformation(1 / 360, 0.5, -1 / 360, 0.5);
}