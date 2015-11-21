library leaflet.layer.vector.test;

import 'dart:html' show document;
import 'package:test/test.dart';
import 'package:leaflet/leaflet.dart';

part 'circle_marker_test.dart';
part 'circle_test.dart';
part 'polygon_test.dart';
part 'polyline_geometry_test.dart';
part 'polyline_test.dart';

vectorTest() {
  circleMarkerTest();
  circleTest();
  polygonTest();
  polylineGeometryTest();
  polylineTest();
}

main() {
  vectorTest();
}
