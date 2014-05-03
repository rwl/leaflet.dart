library leaflet.geo.crs;

import 'dart:math' as math;

// CRS is a base object for all defined CRS (Coordinate Reference Systems) in Leaflet.
class CRS {
  latLngToPoint(latlng, zoom) { // (LatLng, Number) -> Point
    var projectedPoint = this.projection.project(latlng),
        scale = this.scale(zoom);

    return this.transformation._transform(projectedPoint, scale);
  }

  pointToLatLng(point, zoom) { // (Point, Number[, Boolean]) -> LatLng
    var scale = this.scale(zoom),
        untransformedPoint = this.transformation.untransform(point, scale);

    return this.projection.unproject(untransformedPoint);
  }

  project(latlng) {
    return this.projection.project(latlng);
  }

  scale(zoom) {
    return 256 * math.pow(2, zoom);
  }

  getSize(zoom) {
    var s = this.scale(zoom);
    return L.point(s, s);
  }
}