library leaflet.geo.crs;

import 'dart:math' as math;

import '../geo.dart';
import '../projection/projection.dart' as proj;
import '../../geometry/geometry.dart';

part 'epsg3395.dart';
part 'epsg3857.dart';
part 'epsg4326.dart';
part 'simple.dart';

// CRS is a base object for all defined CRS (Coordinate Reference Systems) in Leaflet.
abstract class CRS {
  final proj.Projection projection;
  final Transformation transformation;
  final String code;

  CRS(this.projection, this.transformation, this.code);

  Point latLngToPoint(LatLng latlng, num zoom) { // (LatLng, Number) -> Point
    final projectedPoint = this.projection.project(latlng);
    final scale = this.scale(zoom);

    return this.transformation.destructive_transform(projectedPoint, scale);
  }

  LatLng pointToLatLng(Point point, num zoom) { // (Point, Number[, Boolean]) -> LatLng
    final scale = this.scale(zoom);
    final untransformedPoint = this.transformation.untransform(point, scale);

    return this.projection.unproject(untransformedPoint);
  }

  Point project(LatLng latlng) {
    return this.projection.project(latlng);
  }

  num scale(num zoom) {
    return 256 * math.pow(2, zoom);
  }

  Point getSize(num zoom) {
    var s = this.scale(zoom);
    return new Point(s, s);
  }
}