import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' as L;


main() {
  useHtmlEnhancedConfiguration();
  group('Control.Scale', () {
    test('can be added to an unloaded map', () {
      var map = L.map(document.createElement('div'));
      new L.Control.Scale().addTo(map);
    });
  });
}