
import 'dart:html' show document;

import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/control/control.dart' show Scale;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  //useHtmlEnhancedConfiguration();
  group('control.Scale', () {
    test('can be added to an unloaded map', () {
      final map = new LeafletMap(document.createElement('div'));
      new Scale()..addTo(map);
    });
  });
}
