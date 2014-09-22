library leaflet.geo.test;

import 'dart:math' as Math;

import 'package:unittest/unittest.dart';
import 'package:leaflet/geo/crs/crs.dart' show EPSG3395, EPSG3857;
import 'package:leaflet/geometry/geometry.dart' show Point2D;
import 'package:leaflet/test/test.dart';
import 'package:leaflet/geo/projection/projection.dart' show Mercator;
import 'package:leaflet/geo/geo.dart' show LatLngBounds, LatLng;

part 'crs_test.dart';
part 'lat_lng_bounds_test.dart';
part 'lat_lng_test.dart';
part 'projection_test.dart';

main() {
  crsTest();
  latLngBoundsTest();
  latLngTest();
  projectionTest();
}
