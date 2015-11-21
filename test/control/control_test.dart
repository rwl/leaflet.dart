library leaflet.control.test;

import 'dart:async';
import 'dart:html' as html;
import 'dart:html' show document, Element;
import 'dart:collection' show LinkedHashMap;

import 'package:test/test.dart';

import 'package:leaflet/leaflet.dart';

part 'attribution_test.dart';
part 'layers_test.dart';
part 'scale_test.dart';

controlTest() {
  attributionTest();
  layersTest();
  scaleTest();
}

main() {
  controlTest();
}
