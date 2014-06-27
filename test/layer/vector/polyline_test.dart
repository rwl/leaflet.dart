import 'dart:html' show document;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/layer/vector/vector.dart' show Polyline;

main() {
  useHtmlEnhancedConfiguration();

  group('Polyline', () {

    final c = document.createElement('div');
    c.style.width = '400px';
    c.style.height = '400px';
    final map = new LeafletMap(c);
    map.setView(new LatLng(55.8, 37.6), 6);

    group('#initialize', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
                               [1, 2],
                               [3, 4]
                               ];
        final sourceLatLngs = originalLatLngs.slice();

        final polyline = new Polyline(sourceLatLngs);

        expect(sourceLatLngs, equals(originalLatLngs));
        expect(polyline._latlngs, isNot(equals(sourceLatLngs)));
      });
    });

    group('#setLatLngs', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
                               [1, 2],
                               [3, 4]
                               ];
        final sourceLatLngs = originalLatLngs.slice();

        final polyline = new Polyline(sourceLatLngs);

        polyline.setLatLngs(sourceLatLngs);

        expect(sourceLatLngs, equals(originalLatLngs));
      });
    });

    group('#spliceLatLngs', () {
      test('splices the internal latLngs', () {
        final latLngs = [
                       [1, 2],
                       [3, 4],
                       [5, 6]
                       ];

        final polyline = new Polyline(latLngs);

        polyline.spliceLatLngs(1, 1, [7, 8]);

        expect(polyline._latlngs, equals([new LatLng(1, 2), new LatLng(7, 8), new LatLng(5, 6)]));
      });
    });
  });
}
