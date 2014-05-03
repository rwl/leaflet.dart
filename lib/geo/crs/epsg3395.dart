library leaflet.geo.crs;

import 'dart:math' as math;

class EPSG3395 extends CRS {
  var code = 'EPSG:3395';

  var projection = projection.Mercator;

  var transformation = (() {
    var m = projection.Mercator,
        r = m.R_MAJOR,
        scale = 0.5 / (math.PI * r);

    return new Transformation(scale, 0.5, -scale, 0.5);
  }());
}