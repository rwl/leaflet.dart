library leaflet.geo.test;

import 'dart:math' as Math;

import 'package:unittest/unittest.dart';
import 'package:leaflet/leaflet.dart';

part 'crs_test.dart';
part 'lat_lng_bounds_test.dart';
part 'lat_lng_test.dart';
part 'projection_test.dart';

geoTest() {
  crsTest();
  latLngBoundsTest();
  latLngTest();
  projectionTest();
}

main() => geoTest();
