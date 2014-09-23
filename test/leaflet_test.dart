library leaflet.test;

import 'package:unittest/html_enhanced_config.dart';

import 'map/map_test.dart';
import 'control/control_test.dart';
import 'geo/geo_test.dart';
import 'geometry/geometry_test.dart';
import 'layer/layer_test.dart';
import 'layer/marker/marker_test.dart';
import 'layer/vector/vector_test.dart';

main() {
  useHtmlEnhancedConfiguration();

  mapTest();
  controlTest();
  geoTest();
  geometryTest();
  markerTest();
  vectorTest();
  layerTest();
}
