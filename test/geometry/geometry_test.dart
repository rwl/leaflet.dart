library leaflet.geometry.test;

import 'dart:math' as Math;

import 'package:unittest/unittest.dart';

import 'package:leaflet/geometry/geometry.dart' show Transformation,
  Bounds, Point2D, simplify, clipSegment, pointToSegmentDistance,
  closestPointOnSegment, clipPolygon;

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