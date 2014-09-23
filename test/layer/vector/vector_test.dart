library leaflet.layer.vector.test;

import 'dart:html' show document;
import 'package:unittest/unittest.dart';
import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/layer/vector/vector.dart' show Polygon, Polyline,
  PolylineOptions, Circle, CircleMarker, CircleMarkerOptions;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:unittest/html_enhanced_config.dart';

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
  useHtmlEnhancedConfiguration();
  vectorTest();
}
