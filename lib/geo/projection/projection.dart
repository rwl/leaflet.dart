// Projection contains various geographical projections used by CRS classes.
library leaflet.geo.projection;

import 'dart:math' as math;

import '../geo.dart';
import '../../geometry/geometry.dart';

part 'lon_lat.dart';
part 'mercator.dart';
part 'spherical_mercator.dart';

abstract class Projection {
  Point project(LatLng ll);
  LatLng unproject(Point p);
}