library leaflet.layer.test;

import 'dart:html' show document, Element;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/core/core.dart' show stamp;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/layer/marker/marker.dart' show Marker;
import 'package:leaflet/layer/layer.dart' show FeatureGroup, LayerGroup, Popup;
import 'package:leaflet/core/core.dart' show Event, EventType;
import 'package:leaflet/layer/layer.dart' show GeoJSON;
import 'package:leaflet/layer/tile/tile.dart' show TileLayer, TileLayerOptions;

part 'feature_group_test.dart';
part 'geo_json_test.dart';
part 'layer_group_test.dart';
part 'popup_test.dart';
part 'tile_layer_test.dart';

layerTest() {
  featureGroupTest();
  geoJsonTest();
  layerGroupTest();
  popupTest();
  tileLayerTest();
}

main() {
  useHtmlEnhancedConfiguration();
  layerTest();
}
