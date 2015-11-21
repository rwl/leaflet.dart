library leaflet.layer.test;

import 'dart:async';
import 'dart:html' as html;
import 'dart:html' show document, Element;

import 'package:test/test.dart';
import 'package:leaflet/leaflet.dart';

part 'feature_group_test.dart';
part 'geo_json_test.dart';
part 'layer_group_test.dart';
part 'popup_test.dart';
part 'tile_layer_test.dart';

layerTest() {
  featureGroupTest();
  //geoJsonTest();
  layerGroupTest();
  popupTest();
  tileLayerTest();
}

main() {
  layerTest();
}
