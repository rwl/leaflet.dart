library leaflet.geometry.test;

import 'dart:math' as Math;

import 'package:test/test.dart';
import 'package:leaflet/leaflet.dart';

part 'bounds_test.dart';
part 'line_util_test.dart';
part 'point_test.dart';
part 'poly_util_test.dart';
part 'transformation_test.dart';

geometryTest() {
  boundsTest();
  lineUtilTest();
  pointTest();
  polyUtilTest();
  transformationTest();
}

main() => geometryTest();
