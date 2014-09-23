library leaflet.control.test;

import 'dart:async';
import 'dart:html' as html;
import 'dart:html' show document, Element;
import 'dart:collection' show LinkedHashMap;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/control/control.dart' show Scale, Layers,
  LayersOptions, Attribution, AttributionOptions;

import 'package:leaflet/core/core.dart' show EventType, Event, Action,
  LayersControlEvent;
import 'package:leaflet/layer/tile/tile.dart' show TileLayer;
import 'package:leaflet/layer/marker/marker.dart' show Marker, DefaultIcon;
import 'package:leaflet/layer/layer.dart' show Layer;
import 'package:leaflet/geo/geo.dart' show LatLng;

part 'attribution_test.dart';
part 'layers_test.dart';
part 'scale_test.dart';

controlTest() {
  attributionTest();
  layersTest();
  scaleTest();
}

main() {
  useHtmlEnhancedConfiguration();
  controlTest();
}
