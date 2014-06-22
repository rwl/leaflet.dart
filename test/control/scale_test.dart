
import 'dart:html' show document;

import 'package:leaflet/map/map.dart' show BaseMap;
import 'package:leaflet/control/control.dart' show Scale;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();
  group('Control.Scale', () {
    test('can be added to an unloaded map', () {
      final map = new BaseMap(document.createElement('div'));
      new Scale()..addTo(map);
    });
  });
}
